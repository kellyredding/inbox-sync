require 'inbox-sync/notice/base'

module InboxSync; end
module InboxSync::Notice

  class RunSyncError < Base

    BODY = %{
:error_message

There was an error running this sync.  It has been logged but no mail from this source are being sync'd.  The runner will continue to attempt this sync so mails like this will continue until the problem is fixed.

=====
:error_name
:error_backtrace
    }.strip.freeze

    def initialize(smtp, config, data={})
      @error = data[:error]
      @sync = data[:sync]

      super(smtp, config)
    end

    def subject
      super("#{@sync.uid}")
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
