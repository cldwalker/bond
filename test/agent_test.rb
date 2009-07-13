require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::AgentTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }

  context "InvalidAgent" do
    test "prints error if no action given for mission" do
      capture_stderr { Bond.complete :on=>/blah/ }.should =~ /Invalid mission/
    end

    test "prints error if no condition given" do
      capture_stderr { Bond.complete {|e| []} }.should =~ /Invalid mission/
    end
  
    test "prints error if invalid condition given" do
      capture_stderr { Bond.complete(:on=>'blah') {|e| []} }.should =~ /Invalid mission/
    end
    
    test "prints error if setting mission fails unpredictably" do
      Bond.agent.expects(:complete).raises(ArgumentError)
      capture_stderr { Bond.complete(:on=>/blah/) {|e| [] } }.should =~ /Mission setup failed/
    end
  end

  context "Agent" do
    before(:all) {|e| eval "module ::IRB; module InputCompletor; CompletionProc = lambda {|e| e.to_sym }; end ;end" }
    before(:each) {|e| Bond.agent.instance_eval("@missions = []") }

    test "chooses default mission if no missions match" do
      Bond.complete(:on=>/bling/) {|e| [] }
      Bond.agent.default_mission.expects(:execute)
      complete 'blah'
    end

    test "chooses default mission if internal processing fails" do
      Bond.complete(:on=>/bling/) {|e| [] }
      Bond.agent.expects(:find_mission).raises
      Bond.agent.default_mission.expects(:execute)
      complete('bling')
    end

    test "prints error if action generates failure" do
      Bond.complete(:on=>/bling/) {|e| raise "whoops" }
      capture_stderr { complete('bling') }.should =~ /bling.*whoops/m
    end
  end

  test "default_mission set to a valid mission if irb doesn't exist" do
    Object.expects(:const_defined?).with(:IRB).returns(false)
    Bond.agent.default_mission.is_a?(Bond::Mission).should == true
    Bond.agent.default_mission.action.respond_to?(:call).should == true
  end
end
