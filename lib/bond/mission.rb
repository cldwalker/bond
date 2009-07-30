module Bond
  # Occurs when a mission is incorrectly defined.
  class InvalidMissionError < StandardError; end
  # Occurs when a mission action is incorrectly defined.
  class InvalidMissionActionError < StandardError; end
  # Occurs when a mission or search action fails.
  class FailedExecutionError < StandardError; end
  # Namespace for subclasses of Bond::Mission.
  class Missions; end

  # A set of conditions and actions to take for a completion scenario or mission in Bond's mind.
  class Mission
    include Search

    class<<self
      # default search used across missions
      attr_accessor :default_search
      # Handles creation of proper Mission class depending on the options passed.
      def create(options)
        if options[:method]
          Missions::MethodMission.new(options)
        elsif options[:object]
          Missions::ObjectMission.new(options)
        else
          new(options)
        end
      end
      #:stopdoc:
      def action_object
        @action_object ||= Object.new.extend(Actions)
      end

      def current_eval(string, eval_binding=nil)
        eval_binding ||= default_eval_binding
        eval(string, eval_binding)
      end

      def default_eval_binding
        Object.const_defined?(:IRB) ? IRB.CurrentContext.workspace.binding : ::TOPLEVEL_BINDING
      end

      def default_search
        @default_search ||= :default
      end
      #:startdoc:
    end

    attr_reader :action, :condition, :place
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
      @place = options[:place]
      @search = options.has_key?(:search) ? options[:search] : Mission.default_search
      @search = method("#{@search}_search") unless @search.is_a?(Proc) || @search == false
    end

    # Returns a boolean indicating if a mission matches the given input.
    def matches?(input)
      @matched = @input = @list_prefix = nil
      if (match = handle_valid_match(input))
        @input.instance_variable_set("@matched", @matched)
        @input.instance_eval("def self.matched; @matched ; end")
      end
      !!match
    end

    # Called when a mission has been chosen to autocomplete.
    def execute(input=@input)
      completions = @action.call(input)
      completions = (completions || []).map {|e| e.to_s }
      completions =  @search.call(input || '', completions) if @search
      if @completion_prefix
        @completion_prefix = @completion_prefix.split(Regexp.union(*Readline::DefaultBreakCharacters.split('')))[-1]
        completions = completions.map {|e| @completion_prefix + e }
      end
      completions
    rescue
      error_message = "Mission action failed to execute properly. Check your mission action with pattern #{@condition.inspect}.\n" +
        "Failed with error: #{$!.message}"
      raise FailedExecutionError, error_message
    end

    #:stopdoc:
    def unique_id
      @condition
    end

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
