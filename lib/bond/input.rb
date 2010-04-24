module Bond
  class Input < String
    attr_accessor :object, :matched, :argument, :arguments
    def initialize(str, matched, options={})
      super(str || '')
      @matched = matched
      @object = options[:object] if options[:object]
      @argument = options[:argument] if options[:argument]
      @arguments = options[:arguments] if options[:arguments]
    end

    def inspect
      "#<Bond::Input #{self.to_s.inspect} @matched=#{@matched.to_a.inspect} "+
      "@argument=#{@argument.inspect} @arguments=#{@arguments.inspect} @object=#{@object.inspect}>"
    end
  end
end