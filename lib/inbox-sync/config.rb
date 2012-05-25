require 'logger'
require 'ns-options'
require 'inbox-sync/config/imap_config'
require 'inbox-sync/config/smtp_config'

module InboxSync

  class Config
    include NsOptions::Proxy

    opt :source, IMAPConfig, :required => true, :default => {}
    opt :dest,   IMAPConfig, :required => true, :default => {}
    opt :notify, SMTPConfig, :required => true, :default => {}

    opt :archive_folder, :default => 'Forwarded'
    opt :logger, Logger, :required => true, :default => STDOUT

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
