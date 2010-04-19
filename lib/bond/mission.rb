module Bond
  # Occurs when a mission is incorrectly defined.
  class InvalidMissionError < StandardError; end
  # Occurs when a mission action is incorrectly defined.
  class InvalidMissionActionError < StandardError; end
  # Occurs when a mission or search action fails.
  class FailedExecutionError < StandardError; end

  # A set of conditions and actions to take for a completion scenario or mission in Bond's mind.
  class Mission
    include Search

    class<<self
      # default search used across missions
      attr_accessor :default_search
      # Handles creation of proper Mission class depending on the options passed.
      def create(options)
        if options[:method] || options[:methods] then MethodMission.create(options)
        elsif options[:object]                   then ObjectMission.new(options)
        elsif options[:anywhere]                 then AnywhereMission.new(options)
        else                                          new(options)
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
        (options[:on] || is_a?(DefaultMission))
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
      @matched = @input = @completion_prefix = nil
      (match = _matches?(input)) && create_input(input[/\S+$/])
      !!match
    end

    # Called when a mission has been chosen to autocomplete.
    def execute(input=@input)
      completions = Array(@action.call(input)).map {|e| e.to_s }
      completions =  @search.call(input || '', completions) if @search
      if @completion_prefix
        # Everything up to last break char stays on the line.
        # Must ensure only chars after break are prefixed
        @completion_prefix = @completion_prefix[/([^#{Readline::DefaultBreakCharacters}]+)$/,1] || ''
        completions = completions.map {|e| @completion_prefix + e }
      end
      completions
    rescue
      error_message = "Mission action failed to execute properly. Check your mission action with pattern #{@condition.inspect}.\n" +
        "Failed with error: #{$!.message}"
      raise FailedExecutionError, error_message
    end

    #:stopdoc:
    def eval_object(obj)
      @evaled_object = self.class.current_eval(obj, @eval_binding)
      true
    rescue Exception
      false
    end

    def unique_id
      @condition
    end

    def create_input(input, options={})
      @input = Input.new(input, @matched, options)
    end

    def _matches?(input)
      @matched = input.match(@condition)
    end
    #:startdoc:
  end
end
