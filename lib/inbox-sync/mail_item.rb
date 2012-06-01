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

    def inspect
      "#<#{self.class}:#{'0x%x' % (self.object_id << 1)}: @uid=#{@uid.inspect}, from=#{@message.from.inspect}, subject=#{@message.subject.inspect}, 'INTERNALDATE'=#{@meta['INTERNALDATE'].inspect}>"
    end

    private

    def time_s(datetime)
      datetime.strftime("%a %b %-d %Y, %I:%M %p")
    end

  end

end
