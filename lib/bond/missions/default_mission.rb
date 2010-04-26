# This is the mission called when none of the others match.
class Bond::DefaultMission < Bond::Mission
  #:stopdoc:
  def initialize(options={})
    options[:action] ||= :default
    super
  end
  def default_on; end
  #:startdoc:
end