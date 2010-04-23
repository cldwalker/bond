# Represents a default mission which doesn't need an explicit action.
class Bond::DefaultMission < Bond::Mission
  def initialize(options={}) #:nodoc:
    options[:action] ||= default_action
    super
  end

  def default_on; end

  def default_action #:nodoc:
    Object.const_defined?(:IRB) && IRB.const_defined?(:InputCompletor) ? IRB::InputCompletor::CompletionProc : :default
  end
end