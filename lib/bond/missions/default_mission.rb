# This is the mission called when none of the others match.
class Bond::DefaultMission < Bond::Mission
  ReservedWords = [
    "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined?", "do", "else", "elsif", "end", "ensure",
    "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super",
    "then", "true", "undef", "unless", "until", "when", "while", "yield"
  ]


  # Default action which generates methods, private methods, reserved words, local variables and constants.
  def self.completions(input=nil)
    Bond::Mission.current_eval("methods | private_methods | local_variables | " +
                               "self.class.constants | instance_variables") | ReservedWords
  end

  def initialize(options={}) #@private
    options[:action] ||= self.class.method(:completions)
    super
  end
  def default_on; end #@private
end
