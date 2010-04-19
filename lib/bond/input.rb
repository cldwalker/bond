module Bond
  class Input < String
    attr_reader :object, :matched
    def initialize(str, matched, options={})
      super(str || '')
      @matched = matched
      @object = options[:object] if options[:object]
    end
  end
end