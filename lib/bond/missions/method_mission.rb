# Represents a completion mission specified by :method in Bond.complete.
class Bond::Missions::MethodMission < Bond::Mission
  def initialize(options={}) #:nodoc:
    @method = options.delete(:method)
    @method = Regexp.quote(@method.to_s) unless @method.is_a?(Regexp)
    options[:on] = /^\s*(#{@method})\s*['"]?(.*)$/    
    super
  end

  def set_input(input, match) #:nodoc:
    @input = match[-1]
  end
end
