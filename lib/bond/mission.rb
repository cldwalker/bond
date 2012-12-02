module Bond
  # Occurs when a mission is incorrectly defined.
  class InvalidMissionError < StandardError; end
  # Occurs when a mission fails.
  class FailedMissionError < StandardError
    # Mission that failed
    attr_reader :mission
    def initialize(mission); @mission = mission; end #@private
  end

  # Represents a completion rule, given a condition (:on) on which to match and an action
  # (block or :action) with which to generate possible completions.
  class Mission
    class<<self
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

      # Calls eval with either the irb's current workspace binding or TOPLEVEL_BINDING.
      def current_eval(string, ebinding=Mission.eval_binding)
        ebinding = ebinding.call if ebinding.is_a?(Proc)
        eval(string, ebinding)
      end

      def eval_binding #@private
        @eval_binding || IRB.CurrentContext.workspace.binding rescue ::TOPLEVEL_BINDING
      end
    end

    # All known operator methods
    OPERATORS = %w{% & * ** + - / < << <= <=> == === =~ > >= >> [] []= ^ | ~ ! != !~}
    # Regular expressions which describe common objects for MethodMission and ObjectMission
    OBJECTS = %w<\([^\)]*\) '[^']*' "[^"]*" \/[^\/]*\/> +
      %w<(?:%q|%r|%Q|%w|%s|%)?\[[^\]]*\] (?:proc|lambda|%q|%r|%Q|%w|%s|%)?\s*\{[^\}]*\}>

    # Generates array of possible completions and searches them if search is disabled. Any values
    # that aren't strings are automatically converted with to_s.
    attr_reader :action
    # See {Bond#complete}'s :place.
    attr_reader :place
    # A MatchData object generated from matching the user input with the condition.
    attr_reader :matched
    # Regexp condition
    attr_reader :on
    # Takes same options as {Bond#complete}.
    def initialize(options)
      raise InvalidMissionError, ":action" unless (options[:action] || respond_to?(:default_action, true))
      raise InvalidMissionError, ":on" unless (options[:on] && options[:on].is_a?(Regexp)) || respond_to?(:default_on, true)
      @action, @on = options[:action], options[:on]
      @place = options[:place] if options[:place]
      @name = options[:name] if options[:name]
      @search = options.has_key?(:search) ? options[:search] : Search.default_search
    end

    # Returns a boolean indicating if a mission matches the given Input and should be executed for completion.
    def matches?(input)
      @matched = @input = @completion_prefix = nil
      (match = do_match(input)) && after_match(@line = input)
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

    # Searches possible completions from the action which match the input.
    def call_search(search, input, list)
      Rc.send("#{search}_search", input || '', list)
    rescue
      message = $!.is_a?(NoMethodError) && !Rc.respond_to?("#{search}_search") ?
        "Completion search '#{search}' doesn't exist." :
        "Failed during completion search with '#{$!.message}'."
      raise FailedMissionError.new(self), message
    end

    # Calls the action to generate an array of possible completions.
    def call_action(input)
      @action.respond_to?(:call) ? @action.call(input) : Rc.send(@action, input)
    rescue StandardError, SyntaxError
      message = $!.is_a?(NoMethodError) && !@action.respond_to?(:call) &&
        !Rc.respond_to?(@action) ? "Completion action '#{@action}' doesn't exist." :
        "Failed during completion action '#{name}' with '#{$!.message}'."
      raise FailedMissionError.new(self), message
    end

    # A message used to explains under what conditions a mission matched the user input.
    # Useful for spying and debugging.
    def match_message
      "Matches completion with condition #{condition.inspect}."
    end

    # A regexp representing the condition under which a mission matches the input.
    def condition
      self.class.const_defined?(:CONDITION) ? Regexp.new(self.class.const_get(:CONDITION)) : @on
    end

    # The name or generated unique_id for a mission. Mostly for use with Bond.recomplete.
    def name
      @name ? @name.to_s : unique_id
    end

    # Method which must return non-nil for a mission to match.
    def do_match(input)
      @matched = input.match(@on)
    end

    # Stuff a mission needs to do after matching successfully, in preparation for Mission.execute.
    def after_match(input)
      create_input(input[/\S+$/])
    end

    private
    def condition_with_objects
      self.class.const_get(:CONDITION).sub('OBJECTS', self.class.const_get(:OBJECTS).join('|'))
    end

    def eval_object(obj)
      @evaled_object = self.class.current_eval(obj)
      true
    rescue Exception
      raise FailedMissionError.new(self), "Match failed during eval of '#{obj}'." if Bond.config[:eval_debug]
      false
    end

    def unique_id
      @on.inspect
    end

    def create_input(input, options={})
      @input = Input.new(input, options.merge(:line => @line, :matched => @matched))
    end
  end
end
