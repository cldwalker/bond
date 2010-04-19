require File.join(File.dirname(__FILE__), 'test_helper')

describe "method mission" do
  before_all { Bond.debrief(:readline_plugin=>valid_readline_plugin) }
  before { Bond.agent.reset; Bond.complete(:method=>true) }

  it "completes" do
    complete(:method=>'cool?') {|e| [] }
    complete(:method=>'cool') {|e| %w{ab cd ef gd} }
    tab('cool c').should == %w{cd}
  end

  it "completes quoted argument" do
    complete(:method=>'cool') {|e| %w{ab cd ef ad} }
    tab('cool "a').should == %w{ab ad}
  end

  it "completes parenthetical argument" do
    complete(:method=>'cool') {|e| %w{ab cd ef ad} }
    tab('cool("a').should == %w{ab ad}
  end

  it "needs space to complete argument" do
    complete(:method=>'cool') {|e| %w{ab cd ef ad} }
    tab('coola').should == []
    tab('cool a').should == %w{ab ad}
  end

  it "completes in middle of line" do
    complete(:method=>'cool') {|e| %w{ab cd ef ad} }
    tab('nil; cool a').should == %w{ab ad}
  end

  it "with :methods completes for multiple methods" do
    complete(:method=>%w{cool ls}) {|e| %w{ab cd ef ad}}
    tab("cool a").should == %w{ab ad}
    tab("ls c").should == %w{cd}
  end
end