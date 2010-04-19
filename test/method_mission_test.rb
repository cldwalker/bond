require File.join(File.dirname(__FILE__), 'test_helper')

describe "method mission" do
  before_all { Bond.debrief(:readline_plugin=>valid_readline_plugin) }
  before { Bond.agent.reset; Bond.complete(:method=>true) }

  describe "instance method" do
    before { complete(:method=>'Array#index') {|e| %w{ab cd ef ad} } }

    it "completes" do
      tab('[].index c').should == %w{cd}
    end

    it "completes quoted argument" do
      tab('[].index "a').should == %w{ab ad}
    end

    it "completes parenthetical argument" do
      tab('[].index("a').should == %w{ab ad}
    end

    it "completes symbolic argument" do
      tab('[].index :a').should == %w{:ab :ad}
    end

    it "needs space to complete argument" do
      tab('[].indexa').should == []
      tab('[].index a').should == %w{ab ad}
    end

    it "completes in middle of line" do
      tab('nil; [].index a').should == %w{ab ad}
    end

    it "ignores invalid ruby" do
      tab("[{].index a").should == []
    end

    it "with string :action copies existing action" do
      complete(:method=>"Array#fetch", :action=>"Array#index")
      tab('[].fetch a').should == %w{ab ad}
    end

    it "with invalid :action prints error" do
      capture_stderr {
        complete(:method=>"Array#blah", :action=>'blah')
      }.should =~ /invalid mission action/i
    end
  end

  describe "top-level method" do
    before { complete(:method=>'cool') {|e| %w{ab cd ef ad} } }

    it "completes" do
      complete(:method=>'cool?') {|e| [] }
      tab('cool c').should == %w{cd}
    end

    it "completes in middle of line" do
      tab('nil; cool a').should == %w{ab ad}
    end
  end

  it "with :methods completes for multiple methods" do
    complete(:methods=>%w{cool ls}) {|e| %w{ab cd ef ad}}
    tab("cool a").should == %w{ab ad}
    tab("ls c").should == %w{cd}
  end
end