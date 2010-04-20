module Bond
  class Input < String
    attr_reader :object, :matched, :argument
    def initialize(str, matched, options={})
      super(str || '')
      @matched = matched
      @object = options[:object] if options[:object]
      @argument = options[:argument] if options[:argument]
    end
  end
end