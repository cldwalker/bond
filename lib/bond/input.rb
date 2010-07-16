module Bond
  # A string representing the last word the user has typed. This string is passed to a mission
  # action to generate possible completions. This string contains a number of attributes from the
  # matching mission, useful in generating completions.
  class Input < String
    # Actual object a user has just typed. Used by MethodMission and ObjectMission.
    attr_accessor :object
    # MatchData object from the matching mission (Mission#matched).
    attr_reader :matched
    # Current argument number and array of argument strings. Used by MethodMission.
    attr_accessor :argument, :arguments
    # The full line the user has typed.
    attr_reader :line
    def initialize(str, options={}) #@private
      super(str || '')
      @matched = options[:matched]
      @line = options[:line]
      @object = options[:object] if options[:object]
      @argument = options[:argument] if options[:argument]
      @arguments = options[:arguments] if options[:arguments]
    end

    def inspect #@private
      "#<Bond::Input #{self.to_s.inspect} @matched=#{@matched.to_a.inspect} @line=#{@line.inspect} "+
      "@argument=#{@argument.inspect} @arguments=#{@arguments.inspect} @object=#{@object.inspect}>"
    end
  end
end