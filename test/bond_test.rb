require File.join(File.dirname(__FILE__), 'test_helper')

describe "Bond" do
  describe "debrief" do
    before { Bond.instance_eval("@agent = @config = nil")}
    it "prints error if readline_plugin is not a module" do
      capture_stderr { Bond::M.debrief :readline_plugin=>false }.should =~ /Invalid/
    end
    
    it "prints error if readline_plugin doesn't have all required methods" do
      capture_stderr {Bond::M.debrief :readline_plugin=>Module.new{ def setup; end } }.should =~ /Invalid/
    end

    it "prints no error if valid readline_plugin" do
      capture_stderr {Bond::M.debrief :readline_plugin=>valid_readline_plugin }.should == ''
    end

    it "sets default mission" do
      default_mission = lambda {|e| %w{1 2 3}}
      Bond.reset
      Bond::M.debrief :default_mission=>default_mission, :readline_plugin=>valid_readline_plugin
      tab('1').should == ['1']
    end

    it "sets default search" do
      Bond.reset
      Bond::M.debrief :default_search=>:underscore, :readline_plugin=>valid_readline_plugin
      complete(:on=>/blah/) { %w{all_quiet on_the western_front}}
      tab('blah a_q').should == ["all_quiet"]
      Bond.reset
    end
    after_all { Bond::M.debrief :readline_plugin=>valid_readline_plugin }
  end

  it "reset clears existing missions" do
    complete(:on=>/blah/) {[]}
    Bond.agent.missions.size.should.not == 0
    Bond.reset
    Bond.agent.missions.size.should == 0
  end
end