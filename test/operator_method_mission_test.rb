require File.join(File.dirname(__FILE__), 'test_helper')

describe "operator method mission" do
  before_all { MethodMission.reset }
  before { Bond.agent.reset; Bond.complete(:all_operator_methods=>true) }

  describe "operator" do
    before { complete(:method=>"Hash#[]") { %w{ab cd ae} } }

    it "completes" do
      tab('{}[a').should == ["}[ab", "}[ae"]
    end

    it "completes quoted argument" do
      tab('{:a=>1}["a').should == %w{ab ae}
    end

    it "completes symbolic argument" do
      tab('{}[:a').should == ["}[:ab", "}[:ae"]
    end

    it "completes with no space between method and argument" do
      tab('{}[a').should == ["}[ab", "}[ae"]
    end

    it "completes with space between method and argument" do
      tab('{}[ a').should == ["ab", "ae"]
    end

    it "completes with operator characters in object" do
      tab('{:a=> 1}[').should == ["1}[ab", "1}[cd", "1}[ae"]
    end

    it "completes all arguments with only space as argument" do
      tab('{}[ ').should == ["ab", "cd", "ae"]
    end

    it "completes with a chain of objects" do
      tab('Hash.new[a').should == %w{Hash.new[ab Hash.new[ae}
    end

    it "completes in middle of line" do
      tab('nil; {}[a').should == ["}[ab", "}[ae"]
    end

    it "doesn't complete for multiple arguments" do
      tab('{}[a,').should == []
    end
  end

  it "operator with space between object and method completes" do
    complete(:method=>"Array#*") { %w{ab cd ae} }
    tab('[1,2] * a').should == %w{ab ae}
    tab('[1,2] *a').should == %w{*ab *ae}
  end

  it "class operator completes" do
    complete(:method=>"Hash.*") { %w{ab cd ae} }
    tab('Hash * a').should == %w{ab ae}
  end

  it "with :search completes" do
    complete(:method=>"Array#*", :search=>:anywhere) { %w{abc bcd cde} }
    tab('[1, 2] * b').should == ['abc', 'bcd']
  end
end