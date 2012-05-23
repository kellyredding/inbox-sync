require 'inbox-sync/config'
# require 'net/imap'

module InboxSync

  class Sync

    attr_reader :config, :source_imap, :dest_imap, :notify_smtp

    def initialize(configs={})
      @config = InboxSync::Config.new(configs)
      @source_imap = nil
      @dest_imap   = nil
      @notify_smtp = nil
    end

    def configure(&config_block)
      @config.instance_eval(&config_block)
    end

    def login
      # TOOD: login to both the source and dest IMAP
      # puts "logging in to source..."
      # @source.login('me','secret')
      # @source.select("INBOX")
      # @source.expunge
    end

    def logout
      # TOOD: logout of both the source and dest IMAP
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

  end

end
