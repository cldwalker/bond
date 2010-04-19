# Created with :anywhere in Bond.complete. Is able to complete anywhere i.e. even
# after non word break characters such as '[' or '}'.
class Bond::AnywhereMission < Bond::Mission
  attr_reader :anywhere_condition
  def initialize(options={}) #:nodoc:
    options[:on] = @anywhere_condition = options.delete(:anywhere)
    super
  end

  def create_input(input) #:nodoc:
    @completion_prefix = input.sub(/#{Regexp.escape(@matched[1])}$/, '')
    super @matched[1]
  end

  def unique_id #:nodoc:
    @anywhere_condition
  end
end
