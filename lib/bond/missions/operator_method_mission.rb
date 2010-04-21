module Bond
  class OperatorMethodMission < MethodMission
    OPERATORS = Mission::OPERATORS - ["[]", "[]="]
    CONDITION = %q{(?:^|\s+)(\S+)\s*(%s)\s*(['":])?(.*)$}

    def current_methods
      (OPERATORS & MethodMission.action_methods) + ['[']
    end

    def matched_method
      {'['=>'[]'}[@matched[2]] || @matched[2]
    end

    def after_match(input)
      @action = MethodMission.last_action[1]
      @completion_prefix, typed = input.to_s.sub(/#{@matched[-1]}$/, ''), @matched[-1]
      create_input typed, :object=>@evaled_object, :argument=>1
    end
  end
end