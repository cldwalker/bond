class Bond::Missions::MethodMission < Bond::Mission
  def initialize(options={})
    @method = options.delete(:method)
    @method = Regexp.quote(@method.to_s) unless @method.is_a?(Regexp)
    options[:on] = /^\s*(#{@method})\s*['"]?(.*)$/    
    super
  end

  def set_input(input, match)
    @input = match[-1]
  end
end
