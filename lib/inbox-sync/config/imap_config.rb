require 'ns-options'
require 'ns-options/boolean'
require 'inbox-sync/config/credentials'

module InboxSync; end
class InboxSync::Config

  class IMAPConfig
    include NsOptions::Proxy

    opt :host, :required => true
    opt :port, :default => 143, :required => true
    opt :ssl, NsOptions::Boolean, :default => false, :required => true
    opt :login, Credentials, :required => true, :default => {}
    opt :inbox, :default => "INBOX", :required => true
    opt :expunge, NsOptions::Boolean, :default => true, :required => true

    def validate!
      if !required_set?
        raise ArgumentError, "some required configs are missing"
      end

      login.validate!
    end

  end

end
