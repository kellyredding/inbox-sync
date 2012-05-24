require 'mail'

module InboxSync

  class MailItem

    attr_reader :meta, :message

    def initialize(rfc822, internal_date)
      @meta = {
        'RFC822' => rfc822,
        'INTERNALDATE' => internal_date
      }
      @message = ::Mail.new(rfc822)
    end

  end

end
