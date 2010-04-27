# A mission which completes anywhere i.e. even after non word break characters such as '[' or '}'.
# It generates the following regexp condition /#{prefix}(#{anywhere})$/ and passes the first
# capture group to the mission action.
#
# ==== Bond.complete Options:
# [*:anywhere*] A regexp string which generates the first capture group in the above regexp.
# [*:prefix*] An optional string which prefixes the first capture group in the above regexp.
class Bond::AnywhereMission < Bond::Mission
  def initialize(options={}) #:nodoc:
    options[:on] = Regexp.new("#{options[:prefix]}(#{options[:anywhere]})$")
    super
  end

  def after_match(input) #:nodoc:
    @completion_prefix = input.to_s.sub(/#{Regexp.escape(@matched[1])}$/, '')
    create_input @matched[1]
  end
end
