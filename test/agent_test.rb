require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::AgentTest < Test::Unit::TestCase
  context "InvalidAgent" do
    before(:all) {|e| Bond.debrief(:readline_plugin=>Module.new{ def setup; end; def line_buffer; end }) }
    test "prints error if no action given for mission" do
      capture_stderr { Bond.complete :on=>/blah/ }.should =~ /Invalid mission/
    end

    test "prints error if no condition given" do
      capture_stderr { Bond.complete {|e| []} }.should =~ /Invalid mission/
    end
  
    test "prints error if invalid condition given" do
      capture_stderr { Bond.complete(:on=>'blah') {|e| []} }.should =~ /Invalid mission/
    end
    
    test "prints error if mission fails unpredictably" do
      Bond.agent.expects(:complete).raises(ArgumentError)
      capture_stderr { Bond.complete(:on=>/blah/) {|e| [] } }.should =~ /Mission failed/
    end
  end
end
