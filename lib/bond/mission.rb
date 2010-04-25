module Bond
  # Occurs when a mission is incorrectly defined.
  class InvalidMissionError < StandardError; end
  # Occurs when a mission or search action fails.
  class FailedMissionError < StandardError; end

  # A set of conditions and actions to take for a completion scenario or mission in Bond's mind.
  class Mission
    class<<self
      # default search used across missions
      attr_accessor :default_search
      # eval binding used across missions
      attr_accessor :eval_binding
      # Handles creation of proper Mission class depending on the options passed.
      def create(options)
        if options[:method] || options[:methods] then MethodMission.create(options)
        elsif options[:object]                   then ObjectMission.new(options)
        elsif options[:anywhere]                 then AnywhereMission.new(options)
        elsif options[:all_methods]              then MethodMission.new(options)
        elsif options[:all_operator_methods]     then OperatorMethodMission.new(options)
        else                                          new(options)
        end
      end
      #:stopdoc:
      def current_eval(string, ebinding=eval_binding)
        eval(string, ebinding)
      end

      def eval_binding
        @eval_binding || IRB.CurrentContext.workspace.binding rescue ::TOPLEVEL_BINDING
      end

      def default_search
        @default_search ||= :default
      end
      #:startdoc:
    end

    attr_reader :action, :place, :matched
    OPERATORS = %w{% & * ** + - / < << <= <=> == === =~ > >= >> [] []= ^ | ~}
    OBJECTS = %w<\([^\)]*\) '[^']*' "[^"]*" \/[^\/]*\/> +
      %w<(?:%q|%r|%Q|%w|%s|%)?\[[^\]]*\] (?:proc|lambda|%q|%r|%Q|%w|%s|%)?\s*\{[^\}]*\}>

    # Options are almost the same as those explained at Bond.complete. The only difference is that the action is passed
    # as an :action option here.
    def initialize(options)
      raise InvalidMissionError, ":action" unless (options[:action] || respond_to?(:default_action))
      raise InvalidMissionError, ":on" unless (options[:on] && options[:on].is_a?(Regexp)) || respond_to?(:default_on)
      @action = options[:action]
      @on = options[:on]
      @place = options[:place]
      @search = options.has_key?(:search) ? options[:search] : Mission.default_search
    end

    # Returns a boolean indicating if a mission matches the given input.
    def matches?(input)
      @matched = @input = @completion_prefix = @eval_binding = nil
      (match = do_match(input)) && after_match(input[/\S+$/])
      !!match
    end

    # Called when a mission has been chosen to autocomplete.
    def execute(input=@input)
      completions = Array(call_action(input)).map {|e| e.to_s }
      completions = call_search(@search, input, completions) if @search
      if @completion_prefix
        # Everything up to last break char stays on the line.
        # Must ensure only chars after break are prefixed
        @completion_prefix = @completion_prefix[/([^#{Readline::DefaultBreakCharacters}]+)$/,1] || ''
        completions = completions.map {|e| @completion_prefix + e }
      end
      completions
    end

    def call_search(search, input, list)
      Rc.send("#{search}_search", input || '', list)
    rescue
      message = $!.is_a?(NoMethodError) && !Rc.respond_to?("#{search}_search") ?
        "Completion search '#{search}' doesn't exist." :
        "Failed during completion search with '#{$!.message}'."
      raise FailedMissionError, [message, spy_message]
    end

    def call_action(input)
      @action.respond_to?(:call) ? @action.call(input) : Rc.send(@action, input)
    rescue StandardError, SyntaxError
      message = $!.is_a?(NoMethodError) && !Rc.respond_to?(@action) ?
        "Completion action '#{@action}' doesn't exist." :
        "Failed during completion action with '#{$!.message}'."
      raise FailedMissionError, [message, spy_message]
    end

    def spy_message
      "Matches completion rule with condition #{condition.inspect}."
    end

    def condition
      self.class.const_defined?(:CONDITION) ? Regexp.new(self.class.const_get(:CONDITION)) : @on
    end

    def condition_with_objects
      self.class.const_get(:CONDITION).sub('OBJECTS', self.class.const_get(:OBJECTS).join('|'))
    end

    #:stopdoc:
    def eval_object(obj)
      @evaled_object = self.class.current_eval(obj, eval_binding)
      true
    rescue Exception
      false
    end

    def eval_binding
      @eval_binding ||= self.class.eval_binding
    end

    def unique_id
      @on
    end

    def create_input(input, options={})
      @input = Input.new(input, @matched, options)
    end
    alias_method :after_match, :create_input

    def do_match(input)
      @matched = input.match(@on)
    end
    #:startdoc:
  end
end
