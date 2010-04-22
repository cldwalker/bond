# Created with :method in Bond.complete. Is able to complete first argument for a method.
module Bond
  class MethodMission < Bond::Mission
  class<<self
    attr_accessor :actions, :last_action, :class_actions

    def create(options)
      if options[:action].is_a?(String)
        klass, klass_meth = split_method(options[:action])
        options[:action] = (current_actions(options[:action])[klass_meth] || {})[klass]
      end
      raise InvalidMissionActionError unless options[:action].respond_to?(:call)

      meths = options[:methods] || Array(options[:method])
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
      @last_action = last_action
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

  CONDITION = %q{(?:^|\s+)(\S*?)\.?(%s)(?:\s+|\()(['":])?(.*)$}
  def initialize(options={}) #:nodoc:
    options[:on] = /FILL_PER_COMPLETION/
    @eval_binding = options[:eval_binding]
    super(options)
  end

  def do_match(input)
    @condition = Regexp.new self.class.const_get(:CONDITION) % Regexp.union(*current_methods)
    super && (match = eval_object(@matched[1] ? @matched[1] : 'self') &&
      MethodMission.find_action(@evaled_object, @meth = matched_method))
    match
  end

  def condition
    Regexp.new self.class.const_get(:CONDITION) % '%s'
  end

  def current_methods
    self.class.action_methods - OPERATORS
  end

  def default_action
    MethodMission.last_action[1]
  end

  def matched_method
    @matched[2]
  end

  def after_match(input)
    @action = default_action
    @completion_prefix, typed = @matched[3], @matched[-1]
    arg_count = typed.count(',')
    if typed.to_s.include?(',') && (match = typed.match(/(.*?\s*)([^,]*)$/))
      typed = match[2]
      typed.sub!(/^(['":])/,'')
      @completion_prefix = typed.empty? ? '' : "#{@matched[3]}#{match[1]}#{$1}"
    end
    create_input typed, :object=>@evaled_object, :argument=>1+arg_count
  end

  def spy_message
    "Matches completion rule for method '#{@meth}' in '#{MethodMission.last_action[0]}'."
  end
  end
end