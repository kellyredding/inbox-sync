require 'inbox-sync/notice/run_sync_error'

module InboxSync

  class Runner

    attr_reader :syncs, :interval, :logger

    def initialize(*args)
      opts, syncs = [
        args.last.kind_of?(Hash) ? args.pop : {},
        args.flatten
      ]

      @syncs = syncs || []
      @interval = opts[:interval].kind_of?(Fixnum) ? opts[:interval] : -1
      @logger = opts[:logger] || Logger.new(STDOUT)
      @shutdown = false
      @running_syncs_thread = nil

      Signal.trap('SIGINT', lambda{ self.stop })
      Signal.trap('SIGQUIT', lambda{ self.stop })
    end

    def start
      startup
      loop do
        break if @shutdown
        loop_run
      end
      shutdown
    end

    def stop
      main_log "Stop signal - waiting for any running syncs to finish."
      @shutdown = true
    end

    protected

    def startup
      main_log "Starting up the runner."
    end

    def shutdown
      main_log "Shutting down the runner"
    end

    def loop_run
      main_log "Starting syncs in fresh thread."

      @running_syncs_thread = Thread.new do
        thread_log "starting syncs..."

        begin
          run_syncs
        rescue Exception => err
          thread_log_error(err, :error)
        end

        thread_log "...syncs finished"
      end

      if @interval < 0
        main_log "run-once interval - signaling stop"
        stop
        @interval = 0
      end

      main_log "Sleeping for #{@interval} seconds."
      sleep(@interval)
      main_log "Woke from sleep - waiting for running syncs thread to join..."
      @running_syncs_thread.join
      main_log "... running sycs thread joined."
    end

    def run_syncs
      @syncs.each do |sync|
        begin
          sync.setup
          sync.run
        rescue Exception => err
          run_sync_handle_error(sync, err)
        end

        begin
          sync.teardown
        rescue Exception => err
          run_sync_handle_error(sync, err)
        end
      end
      GC.start
    end

    def run_sync_handle_error(sync, err)
      thread_log_error(err)
      notice = Notice::RunSyncError.new(sync.notify_smtp, sync.config.notify, {
        :error => err,
        :sync => sync
      })
      sync.notify(notice)
    end

    def thread_log_error(err, level=:warn)
      thread_log "#{err.message} (#{err.class.name})", level
      err.backtrace.each { |bt| thread_log bt.to_s, level }
    end

    def main_log(msg, level=:info)
      log "[MAIN]: #{msg}", level
    end

    def thread_log(msg, level=:info)
      log "[THREAD]: #{msg}", level
    end

    def log(msg, level)
      @logger.send(level, msg)
    end

  end

end
