require 'net/imap'
require 'net/smtp'

require 'inbox-sync/config'
require 'inbox-sync/notice/sync_mail_item_error'

module InboxSync

  class Sync

    attr_reader :config, :source_imap, :notify_smtp

    def initialize(configs={})
      @config = InboxSync::Config.new(configs)
      @source_imap = nil
      @notify_smtp = nil
      @logged_in   = false
    end

    def logger
      @config.logger
    end

    def uid
      "#{@config.source.login.user}:#{@config.source.host}"
    end

    def name
      "#{@config.source.login.user} (#{@config.source.host})"
    end

    def logged_in?
      !!@logged_in
    end

    def configure(&config_block)
      @config.instance_eval(&config_block) if config_block
      self
    end

    def setup
      logger.info "=== #{config_log_detail(@config.source)} sync started. ==="

      @notify_smtp ||= setup_smtp(:notify, @config.notify)
      @config.validate!
      login if !logged_in?
    end

    def teardown
      logout if logged_in?
      @source_imap = @notify_smtp = nil
      logger.info "=== #{config_log_detail(@config.source)} sync finished. ==="
    end

    def run(runner=nil)
      return if runner && runner.shutdown?
      each_source_mail_item(runner) do |mail_item|
        begin
          logger.debug "** #{mail_item.inspect}"
          response = send_to_dest(mail_item)
          dest_uid = parse_append_response_uid(response)
          logger.debug "** dest uid: #{dest_uid.inspect}"
        rescue Exception => err
          log_error(err)
          notify(Notice::SyncMailItemError.new(@notify_smtp, @config.notify, {
            :error => err,
            :mail_item => mail_item,
            :sync => self
          }))
        ensure
          archive_on_source(mail_item)
          mail_item = nil
        end
      end
    end

    def notify(notice)
      logger.info "** sending '#{notice.subject}' to #{notice.to.inspect}"
      begin
        notice.send
      rescue Exception => err
        log_error(err)
      end
    end

    protected

    def login
      @source_imap = login_imap(:source, @config.source)
      @logged_in = true
      true
    end

    def logout
      logout_imap(@source_imap, @config.source)
      @logged_in = false
      true
    end

    def each_source_mail_item(runner=nil)
      logger.info "* find: #{config_log_detail(@config.source)}, #{@config.source.inbox.inspect}..."
      items = MailItem.find(@source_imap)
      logger.info "* ...found #{items.size} mail items"

      items.each do |mail_item|
        if runner && runner.shutdown?
          logger.info "* the runner has been shutdown - aborting the sync"
          break
        end
        yield mail_item
      end
      items = nil
    end

    # Send a mail item to the destination:
    # The idea here is that destinations may not accept corrupted or invalid
    # mail items.  If appending the original mail item in any way fails,
    # create a stripped down version of the mail item and try to append that.
    # If appending the stripped down version still fails, error on up
    # and it will be archived and notified.

    def send_to_dest(mail_item)
      begin
        append_to_dest(mail_item)
      rescue Exception => err
        log_error(err)

        logger.debug "** trying to append a the stripped down version"
        append_to_dest(mail_item.stripped, 'stripped down ')
      end
    end

    def append_to_dest(mail_item, desc='')
      logger.info "** Appending #{desc}#{mail_item.uid} to dest #{@config.dest.inbox}..."

      inbox  = @config.dest.inbox
      mail_s = mail_item.rfc822
      flags  = []
      date   = mail_item.internal_date

      using_dest_imap do |imap|
        imap.append(inbox, mail_s, flags, date)
      end
    end

    def archive_on_source(mail_item)
      folder = @config.archive_folder
      if !folder.nil? && !folder.empty?
        logger.debug "** Archiving #{mail_item.uid.inspect}"

        begin
          @source_imap.select(folder)
        rescue Net::IMAP::NoResponseError => err
          logger.debug "* Creating #{folder.inspect} archive folder"
          @source_imap.create(folder)
        ensure
          @source_imap.select(@config.source.inbox)
        end

        mark_as_seen(@source_imap, mail_item.uid)

        logger.debug "** Copying #{mail_item.uid.inspect} to #{folder.inspect}"
        @source_imap.uid_copy(mail_item.uid, folder)
      end

      mark_as_deleted(@source_imap, mail_item.uid)

      expunge_imap(@source_imap, @config.source)

      @source_imap.expunge
    end

    def using_dest_imap
      dest_imap = login_imap(:dest, @config.dest)
      result = yield dest_imap
      logout_imap(dest_imap, @config.dest)
      result
    end

    def login_imap(named, config)
      logger.debug "* LOGIN: #{config_log_detail(config)}"
      begin
        named_imap = Net::IMAP.new(config.host, config.port, config.ssl)
      rescue Errno::ECONNREFUSED => err
        raise Errno::ECONNREFUSED, "#{named} imap {:host => #{config.host}, :port => #{config.port}, :ssl => #{config.ssl}}: #{err.message}"
      end

      begin
        named_imap.login(config.login.user, config.login.pw)
      rescue Net::IMAP::NoResponseError => err
        raise Net::IMAP::NoResponseError, "#{named} imap {:host => #{config.host}, :user => #{config.login.user}}: #{err.message}"
      end

      logger.debug "* SELECT #{config.inbox.inspect}: #{config_log_detail(config)}"
      begin
        named_imap.select(config.inbox)
      rescue Net::IMAP::NoResponseError => err
        raise Net::IMAP::NoResponseError, "#{named} imap: #{err.message}"
      end

      expunge_imap(named_imap, config)

      named_imap
    end

    def expunge_imap(imap, config)
      if config.expunge
        logger.debug "* EXPUNGE #{config.inbox.inspect}: #{config_log_detail(config)}"
        imap.expunge
      end
    end

    def logout_imap(imap, config)
      logger.debug "* LOGOUT: #{config_log_detail(config)}"
      imap.logout
    end

    def setup_smtp(named, config)
      logger.debug "* SMTP: #{config_log_detail(config)}"

      named_smtp = Net::SMTP.new(config.host, config.port)
      named_smtp.enable_starttls if config.tls

      named_smtp
    end

    def config_log_detail(config)
      "host=#{config.host.inspect}, user=#{config.login.user.inspect}"
    end

    def log_error(err)
      logger.warn "#{err.message} (#{err.class.name})"
      err.backtrace.each { |bt| logger.warn bt.to_s }
    end

    # Given a response like this:
    # #<struct Net::IMAP::TaggedResponse tag="RUBY0012", name="OK", data=#<struct Net::IMAP::ResponseText code=#<struct Net::IMAP::ResponseCode name="APPENDUID", data="6 9">, text=" (Success)">, raw_data="RUBY0012 OK [APPENDUID 6 9] (Success)\r\n">
    # (here '9' is the UID)
    def parse_append_response_uid(response)
      response.data.code.data.split(/\s+/).last
    end

    def mark_as_seen(imap, uid)
      logger.debug "** Marking #{uid.inspect} as :Seen"
      imap.uid_store(uid, "+FLAGS", [:Seen])
    end

    def mark_as_deleted(imap, uid)
      logger.debug "** Marking #{uid.inspect} as :Deleted"
      imap.uid_store(uid, "+FLAGS", [:Deleted])
    end

  end

end
