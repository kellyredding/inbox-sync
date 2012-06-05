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

      Signal.trap('SIGINT',  lambda{ raise Interrupt, 'SIGINT'  })
      Signal.trap('SIGQUIT', lambda{ raise Interrupt, 'SIGQUIT' })
      Signal.trap('TERM',    lambda{ raise Interrupt, 'TERM'    })
    end

    def start
      startup!
      loop do
        loop_run
        break if shutdown?
      end
      shutdown!
    end

    def stop
      if @shutdown != true
        main_log "Stop signal - waiting for any running syncs to finish."
        @shutdown = true
      end
    end

    def shutdown?
      !!@shutdown
    end

    protected

    def startup!
      main_log "Starting up the runner."
      if @interval < 0
        main_log "run-once interval - signaling stop"
        stop
        @interval = 0
      end
    end

    def shutdown!
      main_log "Shutting down the runner"
    end

    def loop_run
      begin
        main_log "Starting syncs in fresh thread."
        @running_syncs_thread = Thread.new { run_syncs_thread }

        if @interval > 0
          main_log "Sleeping for #{@interval} second interval."
          sleep(@interval)
          main_log "Woke from sleep"
        end
      rescue Interrupt => err
        stop
      ensure
        join_syncs_thread
      end
    end

    def join_syncs_thread
      begin
        if @running_syncs_thread
          main_log "Waiting for running syncs thread to join..."
          @running_syncs_thread.join
          main_log "... running syncs thread has joined."
        end
        @running_syncs_thread = nil
      rescue Interrupt => err
        stop
        join_syncs_thread
      end
    end

    def run_syncs_thread
      thread_log "starting syncs..."

      begin
        run_syncs
      rescue Exception => err
        thread_log_error(err, :error)
      end

      thread_log "...syncs finished"
    end

    def run_syncs
      @syncs.each do |sync|
        begin
          sync.setup
          sync.run(self)
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
