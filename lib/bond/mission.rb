module Bond
  class InvalidMissionError < StandardError; end
  class Mission
    attr_reader :action, :default

    def initialize(options)
      raise InvalidMissionError unless (options[:action] || options[:object]) &&
        (options[:command] || options[:on] || options[:default] || options[:object])
      raise InvalidMissionError if options[:on] && !options[:on].is_a?(Regexp)
      @action = options[:action]
      @condition = options[:on]
      @default = options[:default] || false
      @search = (options[:search] == false) ? false : (respond_to?("#{options[:search]}_search") ? method("#{options[:search]}_search") :
        method(:default_search))
      if (@command = options[:command])
        @condition = /^\s*(#{@command})\s*['"]?(.*)$/
      elsif (@object = options[:object])
        @condition = /^((\.?[^.]+)+)\.([^.]*)$/
      end
    end

    def matches?(input)
      if (@match = input.match(@condition))
        @input = @command ? @match[2] : input[/\S+$/]
        if @object
          bind = IRB.CurrentContext.workspace.binding rescue ::TOPLEVEL_BINDING
          @evaled_object = eval("#{@match[1]}",bind) rescue nil
          old_match = @match
          if @evaled_object && (@match = @evaled_object.class.ancestors.any? {|e| e.to_s == @object.to_s })
            @action = lambda {|e,m| (@evaled_object.methods(false) + @evaled_object.class.instance_methods(false)).uniq }
            @list_prefix = old_match[1] + "."
            @input = old_match[3]
          else
            @match = false
          end
        end
      end
      !!@match
    end

    def execute(*args)
      if args.empty?
        list = @action.call(@input, @match)
        list = @search ? @search.call(@input, list) : list
        @list_prefix ? list.map {|e| @list_prefix + e } : list
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