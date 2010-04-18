# Created with :method in Bond.complete. Is able to complete first argument for a method.
class Bond::Missions::MethodMission < Bond::Mission
  def self.create(options)
    !options[:method].to_s[/[.#]/] ? new(options) :
      Bond::Missions::ObjectMethodMission.add_method_action(options[:method], &options[:action])
  end

  attr_reader :method_condition
  def initialize(options={}) #:nodoc:
    @method_condition = options.delete(:method)
    @method_condition = Regexp.escape(@method_condition.to_s) unless @method_condition.is_a?(Regexp)
    options[:on] = /(?:^|\s+)(#{@method_condition})(?:\s+|\()['"]?(.*)$/
    super
  end

  def unique_id #:nodoc:
    @method_condition.is_a?(Regexp) ? @method_condition : @method_condition.to_s
  end

  def set_input(input, match) #:nodoc:
    @input = match[-1]
  end
end
