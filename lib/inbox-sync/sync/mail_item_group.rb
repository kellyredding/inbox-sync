module InboxSync
  class Sync; end

  class Sync::MailItemGroup

    attr_reader :thread, :items

    def initialize(sync)
      @sync = sync
      @thread = nil
      @items = []
    end

    def id
      "#<#{self.class}:#{'0x%x' % (self.object_id << 1)}>"
    end

    def add(mail_item)
      @items << mail_item
    end

    def run(runner=nil)
      @runner = runner
      @thread = Thread.new { run_items_thread }
    end

    def join
      @thread.join
      @runner = nil
    end

    protected

    def run_items_thread
      @items.each do |item|
        if @runner && @runner.shutdown?
          @sync.logger.debug "* the runner has been shutdown - aborting #{id} sync thread"
          break
        end
        @sync.run(item)
      end
    end

  end

end
