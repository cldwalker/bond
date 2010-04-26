module Bond
  # An enhanced string representing the last word the user has typed. This string is passed to a mission
  # action to generate possible completions.
  class Input < String
    # Actual object a user has just typed. Used by MethodMission and ObjectMission.
    attr_accessor :object
    # MatchData object of the matching mission.
    attr_reader :matched
    # Argument count and array of argument strings. Used by MethodMission.
    attr_accessor :argument, :arguments
    # The full line the user has typed.
    attr_reader :line
    def initialize(str, options={})
      super(str || '')
      @matched = options[:matched]
      @line = options[:line]
      @object = options[:object] if options[:object]
      @argument = options[:argument] if options[:argument]
      @arguments = options[:arguments] if options[:arguments]
    end

    def inspect #:nodoc:
      "#<Bond::Input #{self.to_s.inspect} @matched=#{@matched.to_a.inspect} @line=#{@line.inspect} "+
      "@argument=#{@argument.inspect} @arguments=#{@arguments.inspect} @object=#{@object.inspect}>"
    end
  end
end