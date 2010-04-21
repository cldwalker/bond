require File.join(File.dirname(__FILE__), 'test_helper')

describe "method mission" do
  before_all {
    Bond.debrief(:readline_plugin=>valid_readline_plugin)
    Bond::MethodMission.actions = {}
    Bond::MethodMission.class_actions = {}
  }
  before { Bond.agent.reset; Bond.complete(:all_methods=>true) }

  describe "method" do
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

    it "completes all arguments with only space as argument" do
      tab('[].index ').should == %w{ab cd ef ad}
    end

    it "completes with a chain of objects" do
      tab('{}.to_a.index a').should == %w{ab ad}
    end

    it "can't have space in object" do
      tab('[1, 2].index c').should == []
    end

    it "completes in middle of line" do
      tab('nil; [].index a').should == %w{ab ad}
    end
  end

  describe "any instance method" do
    before { complete(:method=>'Array#index') {|e| %w{ab cd ef ad} } }

    it "completes for objects of a subclass" do
      class ::MyArray < Array; end
      tab('MyArray.new.index a').should == %w{ab ad}
    end

    it "completes for objects of a subclass using its own definition" do
      class ::MyArray < Array; end
      complete(:method=>'MyArray#index') {|e| %w{aa ab bc} }
      tab('MyArray.new.index a').should == %w{aa ab}
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

  describe "any class method" do
    before { complete(:method=>'Date.parse') {|e| %w{12/01 03/01 01/01} } }

    it "completes" do
      tab('Date.parse 0').should == ["03/01", "01/01"]
    end

    it "completes for a subclass using inherited definition" do
      class ::MyDate < Date; end
      tab('MyDate.parse 0').should == ["03/01", "01/01"]
    end

    it "completes for a subclass using its own definition" do
      class ::MyDate < Date; end
      complete(:method=>'MyDate.parse') {|e| %w{12 03 01} }
      tab('MyDate.parse 0').should == %w{03 01}
    end

    it "with string :action copies existing action" do
      complete(:method=>"Date.blah", :action=>"Date.parse")
      tab('Date.blah 0').should == ["03/01", "01/01"]
    end

    it "doesn't conflict with instance method completion" do
      complete(:method=>'Date#parse') {|e| %w{01 02 23}}
      tab('Date.today.parse 0').should == %w{01 02}
    end
  end

  describe "multi argument method" do
    before { complete(:method=>'Array#index') {|e| %w{ab cd ef ad e,e} } }

    it "completes second argument" do
      tab('[].index ab, a').should == %w{ab ad}
    end

    it "completes second argument as a symbol" do
      tab('[].index ab, :a').should == %w{:ab :ad}
    end

    it "completes second argument as a string" do
      tab('[].index \'ab\' , "a').should == %w{ab ad}
    end

    it "completes third argument" do
      tab('[].index ab, zz, c').should == %w{cd}
    end

    it "completes all arguments after comma" do
      tab('[].index ab,').should == %w{ab cd ef ad e,e}
      tab('[].index ab, ').should == %w{ab cd ef ad e,e}
    end

    it "completes based on argument number" do
      complete(:method=>'blah') {|e| e.argument == 2 ? %w{ab ad} : %w{ab ae} }
      tab('blah a').should == %w{ab ae}
      tab('blah zz, a').should == %w{ab ad}
    end

    it "can't handle a completion with a comma as a completion" do
      tab('[].index e,').should == %w{ab cd ef ad e,e}
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

  it "with :methods completes for multiple instance methods" do
    complete(:methods=>%w{cool ls}) {|e| %w{ab cd ef ad}}
    tab("cool a").should == %w{ab ad}
    tab("ls c").should == %w{cd}
  end

  it "with :methods completes for instance and class methods" do
    complete(:methods=>%w{String#include? String.new}) {|e| %w{ab cd ef ad}}
    tab("'blah'.include? a").should == %w{ab ad}
    tab("String.new a").should == %w{ab ad}
  end

  describe "with :class" do
    it "completes for instance methods" do
      complete(:method=>"blong", :class=>"Array#") { %w{ab cd ef ad} }
      tab('[].blong a').should == %w{ab ad}
      complete(:methods=>["bling"], :class=>"Array#") { %w{ab cd ef ad} }
      tab('[].bling a').should == %w{ab ad}
    end

    it "that is ambiguous defaults to instance methods" do
      complete(:method=>"blong", :class=>"Array") { %w{ab cd ef ad} }
      tab('[].blong a').should == %w{ab ad}
    end

    it "completes for class methods" do
      complete(:method=>"blong", :class=>"Array.") { %w{ab cd ef ad} }
      tab('Array.blong a').should == %w{ab ad}
      complete(:methods=>["bling"], :class=>"Array.") { %w{ab cd ef ad} }
      tab('Array.bling a').should == %w{ab ad}
    end
  end
end