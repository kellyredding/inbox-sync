require 'ns-options'

module InboxSync; end
class InboxSync::Config

  class Credentials
    include NsOptions::Proxy

    opt :user, :required => true
    opt :pw, :required => true

    def initialize(*args)
      if args.size == 1
        self.apply(args.last)
      else
        self.user, self.pw = args
      end
    end

    def validate!
      if !required_set?
        raise ArgumentError, "some required configs are missing"
      end
    end

  end

end
