require 'inbox-sync/notice/base'

module InboxSync; end
module InboxSync::Notice

  class SyncMailItemError < Base

    BODY = %{
:sync_name
:mail_item_name

An error happened while syncing this mail item.  The error
has been logged and the mail item has been archived on the
source.  The sync will continue processing new mail items.

Error
=====
  :error_message (:error_name)
  :error_backtrace
    }.strip.freeze

    def initialize(smtp, config, data={})
      @error = data[:error]
      @mail_item = data[:mail_item]
      @sync = data[:sync]

      super(smtp, config)
    end

    def subject
      super("mail item sync error (#{@mail_item.uid}, #{@sync.uid})")
    end

    def body
      @body ||= BODY.
        gsub(':sync_name', @sync.name).
        gsub(':mail_item_name', @mail_item.name).
        gsub(':error_message', @error.message).
        gsub(':error_name', @error.class.name).
        gsub(':error_backtrace', @error.backtrace.join("\n  "))
    end

  end

end
