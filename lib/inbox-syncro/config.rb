require 'ns-options'
require 'ns-options/boolean'

module InboxSyncro; end

class InboxSyncro::Config
  include NsOptions::Proxy

  class IMAPConfig
    include NsOptions::Proxy

    opt :host, :required => true
    opt :port, :default => 143, :required => true
    opt :ssl,  NsOptions::Boolean, :default => false, :required => true

    ns :login do
      opt :user, :required => true
      opt :pw, :required => true
    end

    opt :inbox,   :default => "INBOX", :required => true
    opt :expunge, NsOptions::Boolean, :default => true, :required => true

    def validate!
      if !required_set?
        raise ArgumentError, "some required configs are missing"
      end

      if !login.required_set?
        raise ArgumentError, "some required :login configs are missing"
      end
    end
  end

  class SMTPConfig
    include NsOptions::Proxy

    opt :host, :required => true
    opt :port, :default => 587, :required => true
    opt :tls,  NsOptions::Boolean, :default => true, :required => true
    opt :helo, :required => true
    opt :user, :required => true
    opt :pw, :required => true
    opt :authtype, :default => :login, :required => true
    opt :to_addrs, :required => true

    def validate!
      if !required_set?
        raise ArgumentError, "some required configs are missing"
      end
    end
  end

  opt :source, IMAPConfig, :required => true, :default => {}
  opt :dest,   IMAPConfig, :required => true, :default => {}
  opt :notify, SMTPConfig, :required => true, :default => {}

  opt :archive_folder, :default => 'Forwarded', :required => true

  def validate!
    if !required_set?
      raise ArgumentError, "some required configs are missing"
    end

    source.validate!
    dest.validate!
    notify.validate!
  end

end
