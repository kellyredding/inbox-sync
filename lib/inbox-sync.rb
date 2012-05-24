require 'inbox-sync/config'
require 'inbox-sync/sync'
require 'inbox-sync/mail_item'

module InboxSync

  def self.new(settings={})
    Sync.new(settings)
  end

end
