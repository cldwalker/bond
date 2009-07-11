module Bond
  class InvalidMissionError < StandardError; end
  class Mission
    attr_reader :command, :pattern, :action, :default

    def initialize(options)
      raise InvalidMissionError unless options[:action] && (options[:command] || options[:on] || options[:default])
      raise InvalidMissionError if options[:on] && !options[:on].is_a?(Regexp)
      @action = options[:action]
      @command = options[:command]
      @pattern = options[:on]
      @default = options[:default]
    end

    def call(*args)
      @action.call(*args)
    end
  end
end