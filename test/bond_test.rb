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

    test "prints no error if valid readline_plugin" do
      capture_stderr {Bond.debrief :readline_plugin=>valid_readline_plugin }.should == ''
    end

    test "sets default mission" do
      default_mission = lambda { %w{1 2 3}}
      Bond.reset
      Bond.debrief :default_mission=>default_mission, :readline_plugin=>valid_readline_plugin
      tabtab('1').should == ['1']
    end

    test "sets default search" do
      Bond.reset
      Bond.debrief :default_search=>:underscore
      complete(:method=>'blah') { %w{all_quiet on_the western_front}}
      tabtab('blah a-q').should == ["all_quiet"]
      Bond.reset
    end
  end

  test "reset clears existing missions" do
    complete(:on=>/blah/) {[]}
    Bond.agent.missions.size.should_not == 0
    Bond.reset
    Bond.agent.missions.size.should == 0
  end
end