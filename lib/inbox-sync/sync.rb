require 'inbox-sync/config'
require 'net/imap'
require 'net/smtp'

module InboxSync

  class Sync

    attr_reader :config, :source_imap, :dest_imap, :notify_smtp

    def initialize(configs={})
      @config = InboxSync::Config.new(configs)
      @source_imap = nil
      @dest_imap   = nil
      @notify_smtp = nil
      @logged_in   = false
    end

    def logger
      @config.logger
    end

    def logged_in?
      !!@logged_in
    end

    def configure(&config_block)
      @config.instance_eval(&config_block) if config_block
      self
    end

    def login
      @config.validate!

      @source_imap = login_imap(:source, @config.source)
      @dest_imap   = login_imap(:dest, @config.dest)
      @notify_smtp = setup_smtp(:notify, @config.notify)

      @logged_in = true
      true
    end

    def logout
      if logged_in?
        logger.info "logging out of source..."
        @source_imap.logout

        logger.info "logging out of dest..."
        @dest_imap.logout

        @source_imap = @dest_imap = @notify_smtp = nil
      end

      @logged_in = false
      true
    end

    def source_mail
      # TODO: return a collection of mail objs that are in the source inbox
      # mail object is a message object and associate meta

      # @msg = @source.uid_fetch(@source.uid_search(['ALL'])[MSG_ID-1], ['RFC822', 'INTERNALDATE']).first

      # # @dest_msgs = @dest_msgs_data.collect do |msg_data|
      # #   ::Mail.new(msg_data.attr['RFC822'])
      # # end

    end

    def append_to_dest(mail)
      # TODO: append the mail into the destination inbox

      # puts "appending msg to dest INBOX..."
      # result = @dest.append("INBOX", @msg.attr['RFC822'], [], @msg.attr['INTERNALDATE'])
      # puts result.inspect

    end

    def archive_source(mail)
      # TODO
    end

    private

    def login_imap(named, config)
      logger.info "logging in to #{named}..."

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

      begin
        named_imap.select(config.inbox)
      rescue Net::IMAP::NoResponseError => err
        raise Net::IMAP::NoResponseError, "#{named} imap: #{err.message}"
      end

      named_imap.expunge if config.expunge
      named_imap
    end

    def setup_smtp(named, config)
      logger.info "setting up #{named}..."

      named_smtp = Net::SMTP.new(config.host, config.port)
      named_smtp.enable_starttls if config.tls
      named_smtp
    end

  end

end
