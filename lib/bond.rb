class Bond
  attr_reader :handlers

  def initialize(options={})
    @handlers = {}
    Readline.completion_proc = self
  end

  def complete(pattern, options={}, &block) 
    @handlers[pattern] = options.merge :block=>block
  end

  def call(input)
    @handlers.each do |pattern,handler| 
      if match = input.match(pattern)
        return handler[:block].call(input, match)
      end
    end
    default_handler(input)
  rescue
    default_handler(input)
  end

  def default_handler(input)
    IRB::InputCompletor::CompletionProc.call(input)
  end
end
