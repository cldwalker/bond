module Bond
  class OperatorMethodMission < MethodMission
    OPERATORS = Mission::OPERATORS - ["[]", "[]="] + ['[']
    CONDITION = %q{(?:^|\s+)(\S+)\s*(%s)\s*(['":])?(.*)$}

    def condition; CONDITION; end
    def object_match; @matched[1] || 'self'; end

    def current_methods
      OPERATORS
    end

    def matched_method
      {'['=>'[]'}[@matched[2]] || @matched[2]
    end
  end
end