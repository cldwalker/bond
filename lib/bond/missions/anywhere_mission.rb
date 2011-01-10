# A mission which completes anywhere i.e. even after non word break characters
# such as '[' or '}'.  With options :prefix and :anywhere, this mission matches
# on the following regexp condition /:prefix?(:anywhere)$/ and passes the first
# capture group to the mission action.
class Bond::AnywhereMission < Bond::Mission
  def initialize(options={}) #@private
    options[:on] = Regexp.new("#{options[:prefix]}(#{options[:anywhere]})$")
    super
  end

  def after_match(input) #@private
    @completion_prefix = input.to_s.sub(/#{Regexp.escape(@matched[1])}$/, '')
    create_input @matched[1]
  end
end
