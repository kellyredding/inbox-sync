require 'ns-options'
require 'inbox-syncro/config/imap_config'
require 'inbox-syncro/config/smtp_config'

module InboxSyncro

  class Config
    include NsOptions::Proxy

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

end
