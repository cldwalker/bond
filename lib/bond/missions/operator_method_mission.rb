module Bond
  # A mission which completes arguments for any module/class method that is an
  # operator i.e. '>' or '*'.  Takes same Bond.complete options as
  # MethodMission. The only operator method this mission doesn't complete is
  # '[]='. The operator '[]' should cover the first argument completion of '[]='
  # anyways.
  class OperatorMethodMission < MethodMission
    OPERATORS = Mission::OPERATORS - ["[]", "[]="]
    OBJECTS = Mission::OBJECTS + %w{\S+}
    CONDITION = %q{(OBJECTS)\s*(METHODS)\s*(['":])?(.*)$}

    protected
    def current_methods
      (OPERATORS & MethodMission.action_methods) + ['[']
    end

    def matched_method
      {'['=>'[]'}[@matched[2]] || @matched[2]
    end

    def after_match(input)
      set_action_and_search
      @completion_prefix, typed = input.to_s.sub(/#{Regexp.quote(@matched[-1])}$/, ''), @matched[-1]
      create_input typed, :object => @evaled_object, :argument => 1
    end
  end
end
