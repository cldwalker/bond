# This is the mission called when none of the others match.
class Bond::DefaultMission < Bond::Mission
  ReservedWords = [
    "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined", "do", "else", "elsif", "end", "ensure",
    "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super",
    "then", "true", "undef", "unless", "until", "when", "while", "yield"
  ]

  #:stopdoc:
  def initialize(options={})
    options[:action] ||= method(:default)
    super
  end
  def default_on; end
  #:startdoc:

  # Default action which generates methods, private methods, reserved words, local variables and constants.
  def default(input)
    Bond::Mission.current_eval("methods | private_methods | local_variables | self.class.constants") | ReservedWords
  end
end