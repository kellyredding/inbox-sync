require 'ns-options'
require 'ns-options/boolean'
require 'inbox-syncro/config/credentials'

module InboxSyncro; end
class InboxSyncro::Config

  class SMTPConfig
    include NsOptions::Proxy

    opt :host, :required => true
    opt :port, :default => 587, :required => true
    opt :tls,  NsOptions::Boolean, :default => true, :required => true
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
