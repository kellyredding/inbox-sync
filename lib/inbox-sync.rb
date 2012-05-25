require 'inbox-sync/mail_item'
require 'inbox-sync/config'
require 'inbox-sync/sync'
require 'inbox-sync/runner'

module InboxSync

  def self.new(settings={})
    Sync.new(settings)
  end

  def self.run(*args)
    Runner.new(*args).start
  end

end
