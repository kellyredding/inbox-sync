require 'ns-options'
require 'ns-options/boolean'
require 'inbox-sync/config/credentials'

module InboxSync; end
class InboxSync::Config

  class SMTPConfig
    include NsOptions::Proxy

    opt :host, :required => true
    opt :port, :default => 25, :required => true
    opt :tls,  NsOptions::Boolean, :default => false, :required => true
    opt :helo, :required => true
    opt :login, Credentials, :required => true, :default => {}
    opt :authtype, :default => :login, :required => true
    opt :to_addrs, :required => true

    def validate!
      if !required_set?
        raise ArgumentError, "some required configs are missing"
      end

      login.validate!
    end

  end

end
