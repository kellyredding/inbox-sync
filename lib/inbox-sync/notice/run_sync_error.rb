require 'inbox-sync/notice/base'

module InboxSync; end
module InboxSync::Notice

  class RunSyncError < Base

    BODY = %{
:sync_name

An error happened while running this sync.  The error has
been logged but no mail items from this sync's source are
being sync'd.  The runner will continue to attempt this
sync so mails like this will continue until the problem
is fixed.

Error
=====
  :error_message (:error_name)
  :error_backtrace
    }.strip.freeze

    def initialize(smtp, config, data={})
      @error = data[:error]
      @sync = data[:sync]

      super(smtp, config)
    end

    def subject
      super("sync run error (#{@sync.uid})")
    end

    def body
      @body ||= BODY.
        gsub(':sync_name', @sync.name).
        gsub(':error_message', @error.message).
        gsub(':error_name', @error.class.name).
        gsub(':error_backtrace', @error.backtrace.join("\n  "))
    end

  end

end
