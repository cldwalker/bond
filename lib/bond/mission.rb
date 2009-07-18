module Bond
  # Occurs when a mission is incorrectly defined.
  class InvalidMissionError < StandardError; end
  # Occurs when a mission action is incorrectly defined.
  class InvalidMissionActionError < StandardError; end
  # Occurs when a mission or search action fails.
  class FailedExecutionError < StandardError; end
  # Namespace for subclasses of Bond::Mission.
  class Missions; end
  # Namespace for mission actions.
  module Actions; end

  # A set of conditions and actions to take for a completion scenario or mission in Bond's mind.
  class Mission
    include Search

    # Handles creation of proper Mission class depending on the options passed.
    def self.create(options)
      if options[:method]
        Missions::MethodMission.new(options)
      elsif options[:object]
        Missions::ObjectMission.new(options)
      else
        new(options)
      end
    end

    def self.action_object
      @action_object ||= Object.new.extend(Actions)
    end

    attr_reader :action, :condition
    OPERATORS = ["%", "&", "*", "**", "+",  "-",  "/", "<", "<<", "<=", "<=>", "==", "===", "=~", ">", ">=", ">>", "[]", "[]=", "^"]

    # Options are almost the same as those explained at Bond.complete. The only difference is that the action is passed
    # as an :action option here.
    def initialize(options)
      raise InvalidMissionError unless (options[:action] || respond_to?(:default_action)) &&
        (options[:on] || is_a?(Missions::DefaultMission))
      raise InvalidMissionError if options[:on] && !options[:on].is_a?(Regexp)
      @action = options[:action].is_a?(Symbol) && self.class.action_object.respond_to?(options[:action]) ?
        self.class.action_object.method(options[:action]) : options[:action]
      raise InvalidMissionActionError if @action && !@action.respond_to?(:call)
      @condition = options[:on]
      @search = options.has_key?(:search) ? options[:search] : method(:default_search)
      @search = method("#{options[:search]}_search") if respond_to?("#{options[:search]}_search")
    end

    # Returns a boolean indicating if a mission matches the given input.
    def matches?(input)
      if (match = handle_valid_match(input))
        @input.instance_variable_set("@matched", @matched)
        @input.instance_eval("def self.matched; @matched ; end")
      end
      !!match
    end

    # Called when a mission has been chosen to autocomplete.
    def execute(*args)
      if args.empty?
        list = (@action.call(@input) || []).map {|e| e.to_s }
        list = @search ? @search.call(@input || '', list) : list
        @list_prefix ? list.map {|e| @list_prefix + e } : list
      else
        @action.call(*args)
      end
    rescue
      error_message = "Mission action failed to execute properly. Check your mission action with pattern #{@condition.inspect}.\n" +
        "Failed with error: #{$!.message}"
      raise FailedExecutionError, error_message
    end

    #:stopdoc:
    def set_input(input, match)
      @input = input[/\S+$/]
    end

    def handle_valid_match(input)
      if (match = input.match(@condition))
        set_input(input, match)
        @matched ||= match
      end
      match
    end
    #:startdoc:
  end
end
