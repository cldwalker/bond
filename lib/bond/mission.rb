module Bond
  class Mission
    attr_reader :command, :pattern

    def initialize(options)
      raise ArgumentError unless options[:action]
      @action = options[:action]
      @command = options[:command]
      @pattern = options[:on]
    end

    def call(*args)
      @action.call(*args)
    end
  end
end