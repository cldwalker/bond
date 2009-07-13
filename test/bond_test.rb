require File.join(File.dirname(__FILE__), 'test_helper')

class BondTest < Test::Unit::TestCase
  context "debrief" do
    before(:each) {|e| Bond.instance_eval("@agent = @config = nil")}
    test "prints error if readline_plugin is not a module" do
      capture_stderr { Bond.debrief :readline_plugin=>false }.should =~ /Invalid/
    end
    
    test "prints error if readline_plugin doesn't have all required methods" do
      capture_stderr {Bond.debrief :readline_plugin=>Module.new{ def setup; end } }.should =~ /Invalid/
    end

    test "no error if valid readline_plugin" do
      capture_stderr {Bond.debrief :readline_plugin=>valid_readline_plugin }.should == ''
    end

    test "sets default mission" do
      default_mission = lambda {}
      Bond.debrief :default_mission=>default_mission, :readline_plugin=>valid_readline_plugin
      Bond.agent.default_mission.action.should == default_mission
    end
  end
end