# Created with :method in Bond.complete. Is able to complete first argument for a method.
class Bond::MethodMission < Bond::Mission
  class<<self
    attr_accessor :actions, :last_action

    def create(options)
      return new(options) if options[:method] == true

      if options[:action].is_a?(String)
        klass, action_meth = split_method(options[:action])
        options[:action] = (@actions[action_meth] || {})[klass]
      end
      raise Bond::InvalidMissionActionError unless options[:action].respond_to?(:call)

      (options[:methods] || Array(options[:method])).each {|meth|
        klass, meth = split_method(meth)
        (@actions[meth] ||= {})[klass] = options[:action]
      }
      nil
    end

    def split_method(meth)
      meth = "Kernel##{meth}" if !meth.to_s[/[.#]/]
      meth.split(/[.#]/,2)
    end

    def find_action(obj, meth)
      @last_action = (@actions[meth] || {}).find {|k,v| get_class(k) && obj.is_a?(get_class(k)) }
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
  self.actions = {}

  attr_reader :meth
  def initialize(options={}) #:nodoc:
    options[:action] = lambda { }
    options[:on] = /FILL_PER_COMPLETION/
    @eval_binding = options[:eval_binding]
    super(options)
  end

  def _matches?(input)
    meths = Regexp.union *self.class.actions.keys
    @condition = /(?:^|\s+)(\S*\.)?(#{meths})(?:\s+|\()(['":])?(.*)$/

    super && (match = eval_object(@matched[1] ? @matched[1].chop : 'self') &&
      self.class.find_action(@evaled_object, @meth = @matched[2]))
    @action = match[1] if match
    match
  end

  def create_input(input)
    @completion_prefix, typed = @matched[3], @matched[-1]
    arg_count = typed.count(',')
    if typed.to_s.include?(',') && (match = typed.match(/(.*?\s*)([^,]*)$/))
      typed = match[2]
      typed.sub!(/^(['":])/,'')
      @completion_prefix = typed.empty? ? '' : "#{@matched[3]}#{match[1]}#{$1}"
    end
    super typed, :object=>@evaled_object, :argument=>1+arg_count
  end
end