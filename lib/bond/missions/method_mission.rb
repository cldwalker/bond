# Represents a completion mission specified by :method in Bond.complete.
class Bond::Missions::MethodMission < Bond::Mission
  attr_reader :method_condition
  def initialize(options={}) #:nodoc:
    @method_condition = options.delete(:method)
    @method_condition = Regexp.quote(@method_condition.to_s) unless @method_condition.is_a?(Regexp)
    options[:on] = /^\s*(#{@method_condition})\s*['"]?(.*)$/
    super
  end

  def set_input(input, match) #:nodoc:
    @input = match[-1]
  end
end
