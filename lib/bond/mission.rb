module Bond
  class InvalidMissionError < StandardError; end
  class FailedExecutionError < StandardError; end
  class Missions; end
  class Mission
    include Search

    def self.create(options)
      if options[:method]
        Missions::MethodMission.new(options)
      elsif options[:object]
        Missions::ObjectMission.new(options)
      else
        new(options)
      end
    end

    attr_reader :action
    OPERATORS = ["%", "&", "*", "**", "+",  "-",  "/", "<", "<<", "<=", "<=>", "==", "===", "=~", ">", ">=", ">>", "[]", "[]=", "^"]

    def initialize(options)
      raise InvalidMissionError unless (options[:action] || respond_to?(:default_action)) &&
        (options[:on] || is_a?(Missions::DefaultMission))
      raise InvalidMissionError if options[:on] && !options[:on].is_a?(Regexp)
      @action = options[:action]
      @condition = options[:on]
      @search = options.has_key?(:search) ? options[:search] : method(:default_search)
      @search = method("#{options[:search]}_search") if respond_to?("#{options[:search]}_search")
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
      error_message = "Mission action failed to execute properly. Check your mission action with pattern #{@condition.inspect}.\n" +
        "Failed with error: #{$!.message}"
      raise FailedExecutionError, error_message
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
  end
end
