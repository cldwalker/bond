module Bond
  class InvalidMissionError < StandardError; end
  class FailedExecutionError < StandardError; end
  class Mission
    attr_reader :action, :default
    OPERATORS = ["%", "&", "*", "**", "+",  "-",  "/", "<", "<<", "<=", "<=>", "==", "===", "=~", ">", ">=", ">>", "[]", "[]=", "^"]

    def initialize(options)
      raise InvalidMissionError unless (options[:action] || options[:object]) &&
        (options[:method] || options[:on] || options[:default] || options[:object])
      raise InvalidMissionError if options[:on] && !options[:on].is_a?(Regexp)
      @action = options[:action]
      @condition = options[:on]
      @default = options[:default] || false
      @eval_binding = options[:eval_binding]
      @search = (options[:search] == false) ? false : (respond_to?("#{options[:search]}_search") ? method("#{options[:search]}_search") :
        method(:default_search))
      if (@method = options[:method])
        @method = Regexp.quote(@method.to_s) unless @method.is_a?(Regexp)
        @condition = /^\s*(#{@method})\s*['"]?(.*)$/
      elsif (@object = options[:object])
        @object = /^#{Regexp.quote(@object.to_s)}$/ unless @object.is_a?(Regexp)
        @condition = /^((\.?[^.]+)+)\.([^.]*)$/
      end
    end

    def matches?(input)
      if (match = input.match(@condition))
        @input = @method ? match[-1] : input[/\S+$/]
        if @object
          @evaled_object = begin eval("#{match[1]}", @eval_binding); rescue Exception; nil end
          old_match = match
          if @evaled_object && (match = @evaled_object.class.ancestors.any? {|e| e.to_s =~ @object })
            @list_prefix = old_match[1] + "."
            @input = old_match[3]
            @input.instance_variable_set("@object", @evaled_object)
            @input.instance_eval("def self.object; @object ; end")
            @action ||= lambda {|e| default_object_action(e.object) }
          else
            match = false
          end
        end
      end
      if match
        @input.instance_variable_set("@matched", match)
        @input.instance_eval("def self.matched; @matched ; end")
      end
      !!match
    end

    def execute(*args)
      if args.empty?
        list = @action.call(@input)
        list = (@search ? @search.call(@input, list) : list) || []
        @list_prefix ? list.map {|e| @list_prefix + e } : list
      else
        @action.call(*args)
      end
    rescue
      error_message = "Mission action failed to execute properly. Check your mission action for pattern #{@condition.inspect}.\n" +
        "Failed with error: #{$!.message}"
      raise FailedExecutionError, error_message
    end

    def default_object_action(obj)
      obj.methods - OPERATORS
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
