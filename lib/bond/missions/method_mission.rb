module Bond
  # A mission which completes arguments for any module/class method that isn't an operator method.
  # To create this mission or OperatorMethodMission, :method or :methods must be passed to Bond.complete.
  # A completion for a given module/class effects any object that has it as an ancestor. If an object
  # has two ancestors that have completions for the same method, the ancestor closer to the object is
  # picked. For example, if Array#collect and Enumerable#collect have completions, argument completion on
  # '[].collect ' would use Array#collect.
  #
  # ==== Bond.complete Options:
  # [:action] If a string, value is assumed to be a :method and that method's action is copied.
  #           Otherwise defaults to normal :action behavior.
  # [:search] If :action is a :method string, defaults to copying its search.
  #           Otherwise defaults to normal :search behavior.
  # [:name, :place] These options aren't supported by a MethodMission/OperatorMethodMission completion.
  # ==== Examples:
  #   Bond.complete(:methods => %w{delete index rindex}, :class => "Array#") {|e| e.object }
  #   Bond.complete(:method => "Hash#index") {|e| e.object.values }
  #
  # ==== Argument Format
  # All method arguments can autocomplete as symbols or strings and the first argument can be prefixed
  # with '(':
  #   >> Bond.complete(:method => 'example') { %w{some example eh} }
  #   => true
  #   >> example '[TAB]
  #   eh    example    some
  #   >> example :[TAB]
  #   :eh   :example   :some
  #
  #  >> example("[TAB]
  #   eh    example    some
  #
  # ==== Multiple Arguments
  # Every time a comma appears after a method, Bond starts a new completion. This allows a method to
  # complete multiple arguments as well as complete keys for a hash. *Each* argument can be have a unique
  # set of completions since a completion action is aware of what argument it is currently completing:
  #   >> Bond.complete(:method => 'FileUtils.chown') {|e|
  #        e.argument > 3 ? %w{noop verbose} : %w{root admin me} }
  #   => true
  #   >> FileUtils.chown 'r[TAB]
  #   >> FileUtils.chown 'root'
  #   >> FileUtils.chown 'root', 'a[TAB]
  #   >> FileUtils.chown 'root', 'admin'
  #   >> FileUtils.chown 'root', 'admin', 'some_file', :v[TAB]
  #   >> FileUtils.chown 'root', 'admin', 'some_file', :verbose
  #   >> FileUtils.chown 'root', 'admin', 'some_file', :verbose => true
  #
  # ==== Developer Notes
  # Unlike other missions, creating these missions with Bond.complete doesn't add more completion rules
  # for an Agent to look through. Instead, all :method(s) completions are handled by one MethodMission
  # object which looks them up with its own hashes. In the same way, all operator methods are
  # handled by one OperatorMethodMission object.
  class MethodMission < Bond::Mission
  class<<self
    # Hash of instance method completions which maps methods to hashes of modules to arrays ([action, search])
    attr_accessor :actions
    # Same as :actions but for class methods
    attr_accessor :class_actions
    # Stores last search result from MethodMission.find
    attr_accessor :last_find
    # Stores class from last search in MethodMission.find
    attr_accessor :last_class

    # Creates a method action given the same options as Bond.complete
    def create(options)
      if options[:action].is_a?(String)
        klass, klass_meth = split_method(options[:action])
        if (arr = (current_actions(options[:action])[klass_meth] || {})[klass])
          options[:action], options[:search] = [arr[0], options[:search] || arr[1]]
        else
          raise InvalidMissionError, "string :action"
        end
      end

      raise InvalidMissionError, "array :method" if options[:method].is_a?(Array)
      meths = options[:methods] || Array(options[:method])
      raise InvalidMissionError, "non-string :method(s)" unless meths.all? {|e| e.is_a?(String) }
      if options[:class].is_a?(String)
        options[:class] << '#' unless options[:class][/[#.]$/]
        meths.map! {|e| options[:class] + e }
      end

      meths.each {|meth|
        klass, klass_meth = split_method(meth)
        (current_actions(meth)[klass_meth] ||= {})[klass] = [options[:action], options[:search]].compact
      }
      nil
    end

    # Resets all instance and class method actions.
    def reset
      @actions = {}
      @class_actions = {}
    end

    # Lists method names
    def action_methods
      (actions.keys + class_actions.keys).uniq
    end

    # Lists full method names, prefixed with class/module
    def all_methods
      (class_actions.map {|m,h| h.map {|k,v| "#{k}.#{m}" } } +
        actions.map {|m,h| h.map {|k,v| "#{k}##{m}" } }).flatten.sort
    end

    # Returns the first completion by looking up the object's ancestors and finding the closest
    # one that has a completion definition for the given method. Completion is returned
    # as an array containing action proc and optional search to go with it.
    def find(obj, meth)
      last_find = find_with(obj, meth, :<=, @class_actions) if obj.is_a?(Module)
      last_find = find_with(obj, meth, :is_a?, @actions) unless last_find
      @last_class = last_find.is_a?(Array) ? last_find[0] : nil
      @last_find = last_find ? last_find[1] : last_find
    end

    # Returns a constant like Module#const_get no matter what namespace it's nested in.
    # Returns nil if the constant is not found.
    def any_const_get(name)
      return name if name.is_a?(Module)
      klass = Object
      name.split('::').each {|e| klass = klass.const_get(e) }
      klass
    rescue
       nil
    end

    protected
    def current_actions(meth)
      meth.include?('.') ? @class_actions : @actions
    end

    def split_method(meth)
      meth = "Kernel##{meth}" if !meth.to_s[/[.#]/]
      meth.split(/[.#]/,2)
    end

    def find_with(obj, meth, find_meth, actions)
      (actions[meth] || {}).select {|k,v| get_class(k) }.
        sort {|a,b| get_class(a[0]) <=> get_class(b[0]) || -1 }.
        find {|k,v| obj.send(find_meth, get_class(k)) }
    end

    def get_class(klass)
      (@klasses ||= {})[klass] ||= any_const_get(klass)
    end
  end

  self.reset
  OBJECTS = Mission::OBJECTS + %w{\S*?}
  CONDITION = %q{(OBJECTS)\.?(METHODS)(?:\s+|\()(['":])?(.*)$}

  def match_message #@private
    "Matches completion for method '#{@meth}' in '#{MethodMission.last_class}'."
  end

  protected
  def do_match(input)
    (@on = default_on) && super && eval_object(@matched[1] ? @matched[1] : 'self') &&
      MethodMission.find(@evaled_object, @meth = matched_method)
  end

  def default_on
    Regexp.new condition_with_objects.sub('METHODS',Regexp.union(*current_methods).to_s)
  end

  def current_methods
    self.class.action_methods - OPERATORS
  end

  def default_action
    MethodMission.last_find[0]
  end

  def matched_method
    @matched[2]
  end

  def set_action_and_search
    @action = default_action
    @search = MethodMission.last_find[1] || Search.default_search
  end

  def after_match(input)
    set_action_and_search
    @completion_prefix, typed = @matched[3], @matched[-1]
    input_options = {:object => @evaled_object, :argument => 1+typed.count(','),
      :arguments => (@completion_prefix.to_s+typed).split(/\s*,\s*/) }
    if typed.to_s.include?(',') && (match = typed.match(/(.*?\s*)([^,]*)$/))
      typed = match[2]
      typed.sub!(/^(['":])/,'')
      @completion_prefix = typed.empty? ? '' : "#{@matched[3]}#{match[1]}#{$1}"
    end
    create_input typed, input_options
  end

  end
end
