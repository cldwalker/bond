require File.join(File.dirname(__FILE__), 'test_helper')

describe "anywhere mission" do
  before { Bond.agent.reset }

  describe "normally" do
    before { complete(:anywhere=>':[^:\s.]*') {|e| %w{:ab :bd :ae} } }

    it "completes at beginning" do
      tab(":a").should == %w{:ab :ae}
    end

    it "completes in middle of string" do
      tab("hash[:a").should == %w{hash[:ab hash[:ae}
    end

    it "completes after word break chars" do
      tab("{:ab=>1}[:a").should == ["1}[:ab", "1}[:ae"]
      tab("nil;:a").should == %w{:ab :ae}
    end
  end

  it 'with special chars and custom search completes' do
    complete(:anywhere=>'\$[^\s.]*', :search=>false) {|e|
      global_variables.grep(/^#{Regexp.escape(e.matched[1])}/)
    }
    tab("$LO").sort.should == ["$LOADED_FEATURES", "$LOAD_PATH"]
  end

  it 'with :prefix completes' do
    complete(:prefix=>'_', :anywhere=>':[^:\s.]*') { %w{:ab :bd :ae} }
    tab("_:a").should == %w{_:ab _:ae}
  end
end