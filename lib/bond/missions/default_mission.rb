class Bond::Missions::DefaultMission < Bond::Mission
  def initialize(options={})
    options[:action] ||= default_action
    super
  end

  def default_action
    Object.const_defined?(:IRB) ? IRB::InputCompletor::CompletionProc : lambda {|e| [] }
  end
end