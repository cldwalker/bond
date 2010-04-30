require File.join(File.dirname(__FILE__), 'test_helper')

describe "Bond" do
  describe "start" do
    before { M.instance_eval("@agent = @config = nil"); M.expects(:load_completions) }
    it "prints error if readline_plugin is not a module" do
      capture_stderr { Bond.start :readline_plugin=>false }.should =~ /Invalid/
    end
    
    it "prints error if readline_plugin doesn't have all required methods" do
      capture_stderr {Bond.start :readline_plugin=>Module.new{ def setup(arg); end } }.should =~ /Invalid/
    end

    it "prints no error if valid readline_plugin" do
      capture_stderr {Bond.start :readline_plugin=>valid_readline_plugin }.should == ''
    end

    it "sets default mission" do
      Bond.start :default_mission=>lambda {|e| %w{1 2 3}}, :readline_plugin=>valid_readline_plugin
      tab('1').should == ['1']
    end

    it "sets default search" do
      Bond.start :default_search=>:underscore, :readline_plugin=>valid_readline_plugin
      complete(:on=>/blah/) { %w{all_quiet on_the western_front}}
      tab('blah a_q').should == ["all_quiet"]
    end

    it "defines completion in block" do
      Bond.start do
        complete(:on=>/blah/) { %w{all_quiet on_the western_front}}
      end
      tab('blah all').should == ["all_quiet"]
    end
    after_all { M.debrief :readline_plugin=>valid_readline_plugin; M.reset }
  end

  it "prints error if Readline setup fails" do
    Bond::Readline.expects(:setup).raises('WTF')
    capture_stderr { Bond.start(:readline_plugin=>Bond::Readline) }.should =~ /Error.*Failed Readline.*'WTF'/
    M.debrief :readline_plugin=>valid_readline_plugin
  end

  it "start prints error for failed completion file" do
    Rc.stubs(:module_eval).raises('wtf')
    capture_stderr { Bond.start }.should =~ /Bond Error: Completion file.*with:\nwtf/
  end

  it "reset clears existing missions" do
    complete(:on=>/blah/) {[]}
    Bond.agent.missions.size.should.not == 0
    M.reset
    Bond.agent.missions.size.should == 0
  end
end