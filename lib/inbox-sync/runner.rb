module InboxSync

  class Runner

    attr_reader :syncs, :timeout

    def initialize(*args)
      opts, syncs = [
        args.last.kind_of?(Hash) ? args.pop : {},
        args.flatten
      ]
      timeout = opts[:timeout]

      @syncs = syncs
      @logger = opts[:logger] || Logger.new(STDOUT)
      @timeout = timeout.kind_of?(Fixnum) ? timeout : -1
      @shutdown = false
      @refresh_lock = false

      Signal.trap('SIGINT', lambda{ self.stop })
      Signal.trap('SIGQUIT', lambda{ self.stop })
    end

    def start
      main_log "Starting the runner."
      loop do
        break if @shutdown
        run_loop
      end

      main_log "Stopping the runner"
      shutdown
    end

    def stop
      main_log "Stop signal - waiting for current thread to finish."
      @shutdown = true
    end

    def shutdown
      main_log "Shutting down."
    end

    private

    def main_log(msg, level=:info)
      log "[MAIN]: #{msg}", level
    end

    def thread_log(msg, level=:info)
      log "[THREAD]: #{msg}", level
    end

    def log(msg, level)
      @logger.send(level, msg)
    end

    def run_loop
      if @refresh_lock
        main_log "Lock is taken."
      else
        main_log "Lock available, starting syncs in fresh thread."
        @refresh_lock = true

        Thread.new do
          thread_log "starting syncs..."

          begin
            run_syncs
          rescue Exception => err
            thread_log "#{err.message} (#{err.class.name})", :error
            err.backtrace.each { |bt| thread_log bt.to_s, :error }
          ensure
            @refresh_lock = false
          end

          thread_log "...syncs finished"
        end
      end


      if @timeout < 0
        main_log "run-once timeout - signaling stop"
        stop
        @timeout = 2
      end

      main_log "Sleeping for #{@timeout} seconds."
      sleep(@timeout)
      main_log "Woke from sleep."
    end

    def run_syncs
      # syncs_to_run = @syncs.dup
      @syncs.each do |sync|
        begin
          sync.login
          sync.run
        rescue Exception => err
          thread_log "#{err.message} (#{err.class.name})", :warn
          err.backtrace.each { |bt| thread_log bt.to_s, :warn }

          # TODO: notify about this
        ensure
          sync.logout
        end
      end
      # syncs_to_run = nil
      GC.start
    end

  end

end
