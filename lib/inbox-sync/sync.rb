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

      @config.validate!
      login if !logged_in?
    end

    def teardown
      logout if logged_in?
      logger.info "=== #{config_log_detail(@config.source)} sync finished. ==="
    end

    def run
      each_source_mail_item do |mail_item|
        begin
          response = send_to_dest(mail_item)
          dest_uid = parse_append_response_uid(response)
          logger.debug "** dest uid: #{dest_uid.inspect}"
          archive_on_source(mail_item)
        rescue Exception => err
          log_error(err)
          notify(Notice::SyncMailItemError.new(@notify_smtp, @config.notify, {
            :error => err,
            :mail_item => mail_item,
            :sync => self,
          }))
        ensure
          # TODO: archive_on_source(mail_item)
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
      @notify_smtp = setup_smtp(:notify, @config.notify)

      @logged_in = true
      true
    end

    def logout
      logout_imap(@source_imap, @config.source)
      @source_imap = @notify_smtp = nil

      @logged_in = false
      true
    end

    def each_source_mail_item
      items = MailItem.find(@source_imap)
      logger.info "* found #{items.size} mails"

      items.each do |mail_item|
        logger.debug "** #{mail_item.inspect}"
        yield mail_item
      end
      items = nil
    end

    def send_to_dest(mail_item)
      # begin
        append_to_dest(mail_item)
      # rescue Exception => err
        # logger.warn "#{err.message} (#{err.class.name})"
        # err.backtrace.each { |bt| logger.warn bt.to_s }

        # stripped_mail_item = mail_item.stripped
        # append_to_dest(stripped_mail_item)
      # end
    end

    def append_to_dest(mail_item)
      logger.info "** Appending #{mail_item.uid} to dest #{@config.dest.inbox}"

      inbox  = @config.dest.inbox
      mail_s = mail_item.meta['RFC822']
      flags  = []
      date   = mail_item.meta['INTERNALDATE']

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
        raise Net::IMAP::NoResponseError, "#{named} imap #{config.login.to_hash.inspect}: #{err.message}"
      end

      logger.debug "* SELECT #{config.inbox.inspect}: #{config_log_detail(config)}"
      begin
        named_imap.select(config.inbox)
      rescue Net::IMAP::NoResponseError => err
        raise Net::IMAP::NoResponseError, "#{named} imap: #{err.message}"
      end

      if config.expunge
        logger.debug "* EXPUNGE #{config.inbox.inspect}: #{config_log_detail(config)}"
        named_imap.expunge
      end

      named_imap
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
