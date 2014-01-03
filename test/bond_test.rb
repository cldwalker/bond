require File.join(File.dirname(__FILE__), 'test_helper')

describe "Bond" do
  describe "start" do
    def start(options={}, &block)
      Bond.start({:readline=>valid_readline}.merge(options), &block)
    end

    before { M.instance_eval("@started = @agent = @config = nil"); M.expects(:load_completions) }
    it "prints error if readline doesn't have all required methods" do
      capture_stderr {
        start :readline=>Module.new{ def self.setup(arg); end }
      }.should =~ /Invalid/
    end

    it "prints error if readline symbol is invalid" do
      capture_stderr {
        start :readline => :blah
      }.should =~ /Invalid.*'blah'/
    end

    it "prints no error if valid readline" do
      capture_stderr { start }.should == ''
    end

    it 'prints no error if valid readline symbol' do
      capture_stderr { start :readline => :ruby }.should == ''
      Bond.config[:readline].should == Bond::Ruby
    end

    it "sets default mission" do
      start :default_mission=>lambda {|e| %w{1 2 3}}
      tab('1').should == ['1']
    end

    it "sets default search" do
      start :default_search=>:anywhere
      complete(:on=>/blah/) { %w{all_quiet on_the western_front}}
      tab('blah qu').should == ["all_quiet"]
    end

    it "defines completion in block" do
      start { complete(:on=>/blah/) { %w{all_quiet on_the western_front}} }
      tab('blah all').should == ["all_quiet"]
    end

    it "sets proc eval_binding" do
      bdg = binding
      start :eval_binding => lambda { bdg }
      Mission.expects(:eval).with(anything, bdg).returns([])
      tab("'blah'.").should == []
    end

    it "status can be checked with started?" do
      Bond.started?.should == false
      start
      Bond.started?.should == true
    end

    after_all { reset }
  end

  describe "start with :gems" do
    before {
      File.stubs(:exist?).returns(true)
      M.stubs(:load_file)
    }

    it "attempts to load gem" do
      M.stubs(:load_dir)
      M.expects(:gem).twice
      start(:gems=>%w{one two})
    end

    it "rescues nonexistent gem" do
      M.stubs(:load_dir)
      M.expects(:gem).raises(LoadError)
      should.not.raise { start(:gems=>%w{blah}) }
    end

    it "rescues nonexistent method 'gem'" do
      M.stubs(:load_dir)
      M.expects(:gem).raises(NoMethodError)
      should.not.raise { start(:gems=>%w{blah}) }
    end

    it "prints error if gem completion not found" do
      M.stubs(:load_dir)
      M.expects(:find_gem_file).returns(nil)
      capture_stderr { start(:gems=>%w{invalid}) }.should =~ /No completions.*'invalid'/
    end

    it "loads gem completion file" do
      M.expects(:load_dir)
      M.expects(:load_dir).with(File.join($:[0], 'awesome', '..', 'bond'))
      M.expects(:load_dir)
      M.expects(:gem)
      start(:gems=>%w{awesome})
    end
    after_all { reset }
  end

  it "prints error if Readline setup fails" do
    Bond::Readline.expects(:setup).raises('WTF')
    capture_stderr { Bond.start(:readline=>Bond::Readline) }.should =~ /Error.*Failed Readline.*'WTF'/
    M.debrief :readline=>valid_readline
  end

  it "start prints error for failed completion file" do
    Rc.stubs(:module_eval).raises('wtf')
    capture_stderr { Bond.start }.should =~ /Bond Error: Completion file.*with:\nwtf/
  end

  it "reset clears existing missions" do
    complete(:on=>/blah/) {[]}
    Bond.agent.missions.size.should.not == 0
    reset
    Bond.agent.missions.size.should == 0
  end

  describe "restart" do
    def start(options={}, &block)
      Bond.start({:readline=>valid_readline}.merge(options), &block)
    end

    it "deletes previous config" do
      start :blah=>''
      Bond.config[:blah].should.not == nil
      Bond.restart({:readline=>valid_readline})
      Bond.config[:blah].should == nil
    end

    it "deletes previous method completions" do
      start
      complete(:method=>'blah') { [] }
      MethodMission.actions['blah'].should.not == nil
      Bond.restart({:readline=>valid_readline})
      MethodMission.actions['blah'].should == nil
    end
  end
end
