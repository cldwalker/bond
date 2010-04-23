module Bond
  class OperatorMethodMission < MethodMission
    OPERATORS = Mission::OPERATORS - ["[]", "[]="]
    OBJECTS = %w{\S+} + Mission::OBJECTS
    CONDITION = %q{(OBJECTS)\s*(METHODS)\s*(['":])?(.*)$}

    def current_methods
      (OPERATORS & MethodMission.action_methods) + ['[']
    end

    def matched_method
      {'['=>'[]'}[@matched[2]] || @matched[2]
    end

    def after_match(input)
      @action = default_action
      @completion_prefix, typed = input.to_s.sub(/#{Regexp.quote(@matched[-1])}$/, ''), @matched[-1]
      create_input typed, :object=>@evaled_object, :argument=>1
    end
  end
end