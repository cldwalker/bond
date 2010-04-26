module Bond
  # A mission which completes arguments for any module/class method. Provides the following
  # options to Bond.complete:
  # ====Options:
  # [*:method*] String representing an instance (Class#method) or class method (Class.method). Creates a
  #             MethodMission or OperatorMethodMission object and uses it to complete a method's arguments.
  #             Gets its class from :class or within string delimited by '#' or '.'. If no class is given,
  #             'Kernel#' is assumed.
  # [*:methods*] Array of instance/class methods in the format of :method.
  # [*:class*] String representing module/class of :method(s). Must end in '#' or '.' to indicate instance/class method.
  class MethodMission < Bond::Mission
  class<<self
    attr_accessor :actions, :last_action, :class_actions, :last_class

    def create(options)
      if options[:action].is_a?(String)
        klass, klass_meth = split_method(options[:action])
        options[:action] = (current_actions(options[:action])[klass_meth] || {})[klass]
      end

      meths = options[:methods] || Array(options[:method])
      raise InvalidMissionError, ":method(s)" unless meths.all? {|e| e.is_a?(String) }
      if options[:class].is_a?(String)
        options[:class] << '#' unless options[:class][/[#.]$/]
        meths.map! {|e| options[:class] + e }
      end

      meths.each {|meth|
        klass, klass_meth = split_method(meth)
        (current_actions(meth)[klass_meth] ||= {})[klass] = options[:action]
      }
      nil
    end

    def reset
      @actions = {}
      @class_actions = {}
    end

    def action_methods
      (actions.keys + class_actions.keys).uniq
    end

    def all_methods
      (class_actions.map {|m,h| h.map {|k,v| "#{k}.#{m}" } } +
        actions.map {|m,h| h.map {|k,v| "#{k}##{m}" } }).flatten.sort
    end

    def current_actions(meth)
      meth.include?('.') ? @class_actions : @actions
    end

    def split_method(meth)
      meth = "Kernel##{meth}" if !meth.to_s[/[.#]/]
      meth.split(/[.#]/,2)
    end

    def find_action(obj, meth)
      last_action = find_action_with(obj, meth, :<=, @class_actions) if obj.is_a?(Module)
      last_action = find_action_with(obj, meth, :is_a?, @actions) unless last_action
      @last_class = last_action[0] if last_action.is_a?(Array)
      @last_action = last_action ? last_action[1] : last_action
    end

    def find_action_with(obj, meth, find_meth, actions)
      (actions[meth] || {}).select {|k,v| get_class(k) }.
        sort {|a,b| get_class(a[0]) <=> get_class(b[0]) || -1 }.
        find {|k,v| obj.send(find_meth, get_class(k)) }
    end

    def get_class(klass)
      (@klasses ||= {})[klass] ||= any_const_get(klass)
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
  end

  self.reset
  OBJECTS = %w{\S*?} + Mission::OBJECTS
  CONDITION = %q{(OBJECTS)\.?(METHODS)(?:\s+|\()(['":])?(.*)$}

  def do_match(input)
    (@on = default_on) && super && eval_object(@matched[1] ? @matched[1] : 'self') &&
      MethodMission.find_action(@evaled_object, @meth = matched_method)
  end

  def default_on
    Regexp.new condition_with_objects.sub('METHODS',Regexp.union(*current_methods).to_s)
  end

  def current_methods
    self.class.action_methods - OPERATORS
  end

  def default_action
    MethodMission.last_action
  end

  def matched_method
    @matched[2]
  end

  def after_match(input)
    @action = default_action
    @completion_prefix, typed = @matched[3], @matched[-1]
    arg_count = typed.count(',')
    input_options = {:object=>@evaled_object, :argument=>1+arg_count,
      :arguments=>(@completion_prefix.to_s+typed).split(/\s*,\s*/) }
    if typed.to_s.include?(',') && (match = typed.match(/(.*?\s*)([^,]*)$/))
      typed = match[2]
      typed.sub!(/^(['":])/,'')
      @completion_prefix = typed.empty? ? '' : "#{@matched[3]}#{match[1]}#{$1}"
    end
    create_input typed, input_options
  end

  def match_message
    "Matches completion for method '#{@meth}' in '#{MethodMission.last_class}'."
  end
  end
end