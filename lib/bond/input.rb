module Bond
  class Input < String
    attr_accessor :object, :matched, :argument, :arguments, :line
    def initialize(str, options={})
      super(str || '')
      @matched = options[:matched]
      @line = options[:line]
      @object = options[:object] if options[:object]
      @argument = options[:argument] if options[:argument]
      @arguments = options[:arguments] if options[:arguments]
    end

    def inspect
      "#<Bond::Input #{self.to_s.inspect} @matched=#{@matched.to_a.inspect} @line=#{@line.inspect} "+
      "@argument=#{@argument.inspect} @arguments=#{@arguments.inspect} @object=#{@object.inspect}>"
    end
  end
end