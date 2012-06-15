module InboxSync
  class Config; end

  class Config::Filter

    attr_reader :conditions, :actions

    def initialize(conditions, &actions)
      @actions = actions

      # make sure all match conditions are regexps
      @conditions = conditions.keys.inject({}) do |processed, key|
        val = conditions[key]
        processed[key] = val.kind_of?(Regexp) ? val : /#{val.to_s}/
        processed
      end
    end

    def match?(message)
      @conditions.keys.inject(true) do |result, key|
        result && value_matches?(message.send(key), @conditions[key])
      end
    end

    protected

    def value_matches?(value, regexp)
      if value.respond_to?(:inject)
        # this is a collection, match if any one item matches
        value.inject(false) do |result, item|
          result || !!(item.to_s =~ regexp)
        end
      else
        # single value match
        !!(value.to_s =~ regexp)
      end
    end

  end

end
