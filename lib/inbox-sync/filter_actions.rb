module InboxSync

  class FilterActions

    attr_reader :message

    def initialize(message)
      @message = message
      @copies  = @flags = []
    end

    def copies; @copies.uniq; end
    def flags;  @flags.uniq;  end

    def copy_to(*folders)
      @copies += args_collection(folders)
    end
    alias_method :label, :copy_to

    def move_to(*folders)
      copy_to *folders
      delete
    end
    alias_method :archive_to, :move_to

    def flag(*flags)
      @flags += args_collection(flags).map{|f| f.to_sym}
    end

    def mark_read
      flag(:Seen)
    end

    def delete
      flag(:Deleted)
    end

    def match!(filters)
      filters.each do |filter|
        instance_eval(&filter.actions) if filter.match?(@message)
      end
    end

    def apply!(imap, uid)
      apply_flags(imap, uid)
      apply_copies(imap, uid)

      # force make the dest message unread if not explicitly marked :Seen
      if !flags.include?(:Seen)
        imap.uid_store(uid, "-FLAGS", [:Seen])
      end
    end

    protected

    def apply_flags(imap, uid)
      if !flags.empty?
        imap.uid_store(uid, "+FLAGS", flags)
      end
    end

    def apply_copies(imap, uid)
      copies.each do |folder|
        begin
          imap.uid_copy(uid, folder)
        rescue Net::IMAP::NoResponseError
          imap.create(folder)
          retry
        end
      end
    end

    private

    def args_collection(args)
      args.
        flatten.
        compact.
        map {|f| f.to_s}.
        reject {|f| f.empty?}.
        uniq
    end

  end

end
