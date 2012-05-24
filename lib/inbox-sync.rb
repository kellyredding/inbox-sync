require 'inbox-sync/config'
require 'inbox-sync/sync'

module InboxSync

  def self.new(settings={})
    Sync.new(settings)
  end

end
