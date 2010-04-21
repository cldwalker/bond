module Bond
  class OperatorMethodMission < MethodMission
    OPERATORS = Mission::OPERATORS - ["[]", "[]="] + ['[']
    CONDITION = %q{(?:^|\s+)(\S+)\s*(%s)\s*(['":])?(.*)$}

    def condition; CONDITION; end

    def current_methods
      OPERATORS
    end

    def matched_method
      {'['=>'[]'}[@matched[2]] || @matched[2]
    end

    def create_input(input)
      @completion_prefix, typed = input.sub(/#{@matched[-1]}$/, ''), @matched[-1]
      @input = Input.new typed, @matched, :object=>@evaled_object, :argument=>1
    end
  end
end