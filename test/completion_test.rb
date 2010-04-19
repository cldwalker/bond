require File.join(File.dirname(__FILE__), 'test_helper')

describe "Completion" do
  before_all { Bond.reset; Bond.debrief(:readline_plugin=>valid_readline_plugin)
    require 'bond/completion'
    Bond::Missions::ObjectMethodMission.method_actions = {}
  }

  it "completes object methods anywhere" do
    matches = tab("blah :man.")
    matches.size.should.be > 0
    matches.should.be.all {|e| e=~ /^:man/}
  end

  it "completes global variables anywhere" do
    tab("blah $LOA").should.satisfy {|e|
      e.size > 0 && e.all? {|e| e=~ /^\$LOA/} }
    tab("h[$LOAD_").should == ["h[$LOAD_PATH"]
  end

  it "completes absolute constants anywhere" do
    tab("blah ::Arr").should == ["::Array"]
    tab("h[::Arr").should == ["h[::Array"]
  end

  it "completes nested classes anywhere" do
    mock_irb
    tab("blah IRB::In").should == ["IRB::InputCompletor"]
  end

  it "completes symbols anywhere" do
    Symbol.expects(:all_symbols).twice.returns([:mah])
    tab("blah :m").size.should.be > 0
    tab("blah[:m").should == ["blah[:mah"]
  end

  it "completes string methods anywhere" do
    tab("blah 'man'.f").should.include('.freeze')
  end

  it "methods don't swallow up default completion" do
    Bond.agent.find_mission("Bond.complete(:method=>'blah') { Arr").should == nil
  end
end