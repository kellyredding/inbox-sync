require 'mail'

module InboxSync

  class MailItem

    def self.find(imap)
      imap.uid_search(['ALL']).map do |uid|
        self.new(imap, uid)
      end
    end

    attr_reader :imap, :uid

    def initialize(imap, uid, attrs={})
      @imap = imap
      @uid = uid
      @rfc822 = attrs[:rfc822]
      @internal_date = attrs[:internal_date]
      @message = attrs[:message]
    end

    def name
      @name ||= "[#{self.uid}] #{self.message.from}: #{self.message.subject.inspect} (#{time_s(self.message.date)})"
    end

    def meta
      @meta ||= begin
        fetch_data = @imap.uid_fetch(self.uid, ['RFC822', 'INTERNALDATE'])
        if fetch_data.nil? || fetch_data.empty?
          raise "error fetching data for uid '#{self.uid}'"
        end
        fetch_data.first
      end
    end

    def rfc822
      @rfc822 ||= self.meta.attr['RFC822']
    end

    def rfc822=(value)
      @rfc822 = value
    end

    def internal_date
      @internal_date ||= self.meta.attr['INTERNALDATE']
    end

    def internal_date=(value)
      @internal_date = value
    end

    def message
      @message ||= ::Mail.new(self.rfc822)
    end

    def message=(value)
      @message = value
    end

    # Returns a stripped down version of the mail item
    # The stripped down versions is just the 'text/plain' part of multipart
    # mail items.  If the original mail item was not multipart, then the
    # stripped down version is the same as the original.
    # This implies that stripped down mail items have no attachments.

    def stripped
      @stripped ||= strip_down(copy_mail_item(self))
    end

    def inspect
      "#<#{self.class}:#{'0x%x' % (self.object_id << 1)}: @uid=#{self.uid.inspect}, from=#{self.message.from.inspect}, subject=#{self.message.subject.inspect}, 'INTERNALDATE'=#{self.internal_date.inspect}>"
    end

    private

    def time_s(datetime)
      if datetime && datetime.respond_to?(:strftime)
        datetime.strftime("%a %b %-d %Y, %I:%M %p")
      else
        datetime
      end
    end

    def copy_mail_item(item)
      MailItem.new(item.imap, item.uid, {
        :rfc822 => item.rfc822,
        :internal_date => item.internal_date,
        :message => item.message
      })
    end

    def strip_down(mail_item)
      message = mail_item.message
      if message.multipart?
        message.parts.delete_if do |part|
          !part.content_type.match(/text\/plain/)
        end
        message.parts.first.body = strip_down_body_s(message.parts.first.body)
        mail_item.message = message
        mail_item.rfc822 = message.to_s
      end
      mail_item
    end

    def strip_down_body_s(body_s)
      "**[inbox-sync] stripped down to just plain text part**\n\n#{body_s}"
    end

  end

end
