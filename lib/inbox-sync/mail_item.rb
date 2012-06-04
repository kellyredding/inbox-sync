require 'mail'

module InboxSync

  class MailItem

    def self.find(imap)
      imap.uid_search(['ALL']).
        map do |uid|
          [uid, imap.uid_fetch(uid, ['RFC822', 'INTERNALDATE']).first]
        end.
        map do |uid_meta|
          self.new(
            uid_meta.first,
            uid_meta.last.attr['RFC822'],
            uid_meta.last.attr["INTERNALDATE"]
          )
        end
    end

    attr_reader :uid, :meta, :message

    def initialize(uid, rfc822, internal_date)
      @uid = uid
      @meta = {
        'RFC822' => rfc822,
        'INTERNALDATE' => internal_date
      }
      @message = ::Mail.new(rfc822)
    end

    def name
      "[#{@uid}] #{@message.from}: #{@message.subject.inspect} (#{time_s(@message.date)})"
    end

    # Returns a stripped down version of the mail item
    # The stripped down versions is just the 'text/plain' part of multipart
    # mail items.  If the original mail item was not multipart, then the
    # stripped down version is the same as the original.
    # This implies that stripped down mail items have no attachments.

    def stripped
      @stripped ||= strip_down(MailItem.new(
        self.uid,
        self.meta['RFC822'],
        self.meta["INTERNALDATE"]
      ))
    end

    def inspect
      "#<#{self.class}:#{'0x%x' % (self.object_id << 1)}: @uid=#{@uid.inspect}, from=#{@message.from.inspect}, subject=#{@message.subject.inspect}, 'INTERNALDATE'=#{@meta['INTERNALDATE'].inspect}>"
    end

    private

    def time_s(datetime)
      datetime.strftime("%a %b %-d %Y, %I:%M %p")
    end

    def strip_down(mail_item)
      message = mail_item.message
      if message.multipart?
        message.parts.delete_if do |part|
          !part.content_type.match(/text\/plain/)
        end
        message.parts.first.body = strip_down_body_s(message.parts.first.body)
        mail_item.meta['RFC822'] = message.to_s
      end
      mail_item
    end

    def strip_down_body_s(body_s)
      "**[inbox-sync] stripped down to just plain text part**\n\n#{body_s}"
    end

  end

end
