module Bond
  class InvalidMissionError < StandardError; end
  class FailedExecutionError < StandardError; end
  class Missions; end
  class Mission
    def self.create(options)
      if options[:method]
        Missions::MethodMission.new(options)
      elsif options[:object]
        Missions::ObjectMission.new(options)
      else
        new(options)
      end
    end

    attr_reader :action, :default
    OPERATORS = ["%", "&", "*", "**", "+",  "-",  "/", "<", "<<", "<=", "<=>", "==", "===", "=~", ">", ">=", ">>", "[]", "[]=", "^"]

    def initialize(options)
      raise InvalidMissionError unless (options[:action] || respond_to?(:default_action)) &&
        (options[:on] || options[:default])
      raise InvalidMissionError if options[:on] && !options[:on].is_a?(Regexp)
      @action = options[:action]
      @condition = options[:on]
      @default = options[:default] || false
      @search = (options[:search] == false) ? false : (respond_to?("#{options[:search]}_search") ? method("#{options[:search]}_search") :
        method(:default_search))
    end

    def set_input(input, match)
      @input = input[/\S+$/]
    end

    def handle_valid_match(input)
      if (match = input.match(@condition))
        set_input(input, match)
      end
      match
    end

    def matches?(input)
      if (match = handle_valid_match(input))
        @input.instance_variable_set("@matched", match)
        @input.instance_eval("def self.matched; @matched ; end")
      end
      !!match
    end

    def execute(*args)
      if args.empty?
        list = @action.call(@input)
        list = (@search ? @search.call(@input, list) : list) || []
        @list_prefix ? list.map {|e| @list_prefix + e } : list
      else
        @action.call(*args)
      end
    rescue
      error_message = "Mission action failed to execute properly. Check your mission action for pattern #{@condition.inspect}.\n" +
        "Failed with error: #{$!.message}"
      raise FailedExecutionError, error_message
    end

    def default_search(input, list)
      list.grep(/^#{input}/)
    end

    def underscore_search(input, list)
      split_input = input.split("-").join("")
      list.select {|c|
        c.split("_").map {|g| g[0,1] }.join("") =~ /^#{split_input}/ || c =~ /^#{input}/
      }
    end
  end
end
