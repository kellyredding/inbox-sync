require 'logger'
require 'ns-options'
require 'inbox-sync/config/imap_config'
require 'inbox-sync/config/smtp_config'
require 'inbox-sync/config/filter'

module InboxSync

  class Config
    include NsOptions::Proxy

    opt :source, IMAPConfig, :required => true, :default => {}
    opt :dest,   IMAPConfig, :required => true, :default => {}
    opt :notify, SMTPConfig, :required => true, :default => {}

    opt :archive_folder, :default => 'Archived'
    opt :logger, Logger, :required => true, :default => STDOUT
    opt :filters, :default => [], :required => true

    def filter(*args, &block)
      filters << Filter.new(*args, &block)
    end

    def validate!
      if !required_set?
        raise ArgumentError, "some required configs are missing"
      end

      source.validate!
      dest.validate!
      notify.validate!
    end

    protected

    def contains(value);    /.*#{value}.*/; end
    def starts_with(value); /\A#{value}.*/; end
    def ends_with(value);   /.*#{value}\Z/; end

    alias_method :like, :contains
    alias_method :includes, :contains
    alias_method :sw, :starts_with
    alias_method :ew, :ends_with

  end

end
