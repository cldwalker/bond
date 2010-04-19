# Created with :method in Bond.complete. Is able to complete first argument for a method.
class Bond::MethodMission < Bond::Mission
  class<<self
    attr_accessor :method_actions, :last_match
    def create(options)
      return new(options) if options[:method] == true
      (options[:methods] || Array(options[:method])).each do |meth|
        meth = "Kernel##{meth}" if !meth.to_s[/[.#]/]
        if options[:action].is_a?(String)
          options[:action] = method_action(*options[:action].split(/[.#]/,2))[1]
        end
        raise Bond::InvalidMissionActionError unless options[:action].respond_to?(:call)
        add_method_action(meth, &options[:action])
      end
      nil
    end

    def method_action(obj, meth)
      @last_match = (@method_actions[meth] || {}).find {|k,v| get_class(k) && obj.is_a?(get_class(k)) }
    end

    def add_method_action(meth_klass, &block)
      klass, meth = meth_klass.split(/[.#]/,2)
      (@method_actions[meth] ||= {})[klass] = block
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
  self.method_actions = {}

  attr_reader :meth
  def initialize(options={}) #:nodoc:
    options[:action] = lambda { }
    options[:on] = /FILL_PER_COMPLETION/
    @eval_binding = options[:eval_binding]
    super(options)
  end

  def handle_valid_match(input)
    meths = Regexp.union *self.class.method_actions.keys
    @condition = /(?:^|\s+)([^\s.]+)?\.?(#{meths})(?:\s+|\()(['":])?(.*)$/
    if (match = super) && (match = eval_object(match) &&
      self.class.method_action(@evaled_object, @meth))
      @completion_prefix = @matched[3]
      @input = @matched[-1] || ''
      @input.instance_variable_set("@object", @evaled_object)
      class<<@input; def object; @object; end; end
      @action = match[1]
    end
    match
  end

  def eval_object(match)
    @matched = match
    @evaled_object = self.class.current_eval(match[1] || 'self', @eval_binding)
    @meth = @matched[2]
    true
  rescue Exception
    false
  end
end