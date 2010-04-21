# Created with :anywhere in Bond.complete. Is able to complete anywhere i.e. even
# after non word break characters such as '[' or '}'.
class Bond::AnywhereMission < Bond::Mission
  def initialize(options={}) #:nodoc:
    options[:on] = options.delete(:anywhere)
    super
  end

  def after_match(input) #:nodoc:
    @completion_prefix = input.to_s.sub(/#{Regexp.escape(@matched[1])}$/, '')
    create_input @matched[1]
  end

  def unique_id #:nodoc:
    @anywhere_condition
  end
end
