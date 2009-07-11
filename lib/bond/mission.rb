module Bond
  class InvalidMissionError < StandardError; end
  class Mission
    attr_reader :action, :default

    def initialize(options)
      raise InvalidMissionError unless options[:action] && (options[:command] || options[:on] || options[:default])
      raise InvalidMissionError if options[:on] && !options[:on].is_a?(Regexp)
      @action = options[:action]
      @condition = options[:on]
      @default = options[:default]
      @command = options[:command]
      @condition = /^\s*(#{@command})\s*(.*)$/ if @command
    end

    def matches?(input)
      @input = input
      if (@match = input.match(@condition)) && @command
        @input = @match[2]
      end
      !!@match
    end

    def execute(*args)
      args.empty? ? @action.call(@input, @match) : @action.call(*args)
    end
  end
end