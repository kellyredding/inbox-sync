require 'mail'

module InboxSync; end
module InboxSync::Notice

  class Base

    attr_reader :mail

    def initialize(smtp, config)
      @smtp = smtp
      @config = config

      @mail = ::Mail.new
      @mail.from = self.from
      @mail.to = self.to
      @mail.subject = self.subject
      @mail.body = self.body
    end

    def from; @config.from_addr; end
    def to;   @config.to_addr;   end

    def subject(msg="notice")
      "[inbox-sync] #{msg}"
    end

    def body
      raise RuntimeError, "subclass `Notice::Base` and define your body"
    end

    def send
      @smtp.start(helo, user, pw, authtype) do |smtp|
        smtp.send_message(@mail.to_s, from, to)
      end
    end

    protected

    def helo;     @config.helo;       end
    def user;     @config.login.user; end
    def pw;       @config.login.pw;   end
    def authtype; @config.authtype;   end

  end

end
