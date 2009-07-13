module Bond
  class InvalidMissionError < StandardError; end
  class Mission
    attr_reader :action, :default

    def initialize(options)
      raise InvalidMissionError unless options[:action] && (options[:command] || options[:on] || options[:default])
      raise InvalidMissionError if options[:on] && !options[:on].is_a?(Regexp)
      @action = options[:action]
      @condition = options[:on]
      @default = options[:default] || false
      @search = (options[:search] == false) ? false : (respond_to?("#{options[:search]}_search") ? method("#{options[:search]}_search") :
        method(:default_search))
      if (@command = options[:command])
        @condition = /^\s*(#{@command})\s*['"]?(.*)$/
      end
    end

    def matches?(input)
      if (@match = input.match(@condition))
        @input = @command ? @match[2] : input[/\S+$/]
      end
      !!@match
    end

    def execute(*args)
      if args.empty?
        list = @action.call(@input, @match)
        @search ? @search.call(@input, list) : list
      else
        @action.call(*args)
      end
    end

    def default_search(input, list)
      list.grep(/^#{input}/)
    end

    def underscore_search(input, list)
      split_input = input.split("-").join("")
      list.select {|c|
        c.split("_").map {|g| g[0,1] }.join("") =~ /^#{split_input}/ || c =~ /^#{input}/
      }
    end
  end
end