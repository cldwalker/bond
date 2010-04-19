require File.join(File.dirname(__FILE__), 'test_helper')

describe "Mission" do
  before_all { Bond.debrief(:readline_plugin=>valid_readline_plugin) }

  describe "mission" do
    before { Bond.agent.reset }
    it "completes" do
      complete(:on=>/bling/) {|e| %w{ab cd fg hi}}
      complete(:method=>'cool') {|e| [] }
      tab('some bling f').should == %w{fg}
    end

    it "with regexp condition completes" do
      complete(:on=>/\s*'([^']+)$/, :search=>false) {|e| %w{coco for puffs}.grep(/#{e.matched[1]}/) }
      tab("require 'ff").should == ['puffs']
    end

    it "with non-string completions completes" do
      complete(:on=>/.*/) { [:one,:two,:three] }
      tab('ok ').should == %w{one two three}
    end

    it "with non-array completions completes" do
      complete(:on=>/blah/) { 'blah' }
      tab('blah ').should == ['blah']
    end

    it "with symbol action completes" do
      eval %[module ::Bond::Actions; def blah(input); %w{one two three}; end; end]
      complete(:on=>/blah/, :action=>:blah)
      tab('blah ').should == %w{one two three}
    end

    it "with invalid action prints error" do
      complete(:on=>/bling/) {|e| raise "whoops" }
      capture_stderr { tab('bling') }.should =~ /bling.*whoops/m
    end

    it "always passes string to action block" do
      complete(:on=>/man/) {|e| e.should.be.is_a(String); [] }
      tab('man ')
    end
  end

  describe "anywhere mission" do
    before { Bond.agent.reset }

    it "at beginning completes" do
      complete(:anywhere=>/(:[^:\s.]*)$/) {|e| %w{:ab :bd :ae} }
      tab(":a").should == %w{:ab :ae}
    end

    it "in middle of string completes" do
      complete(:anywhere=>/(:[^:\s.]*)$/) {|e| %w{:ab :bd :ae} }
      tab("hash[:a").should == %w{hash[:ab hash[:ae}
    end

    it "after word break chars completes" do
      complete(:anywhere=>/(:[^:\s.]*)$/) {|e| %w{:ab :bd :ae} }
      tab("{:ab=>1}[:a").should == ["1}[:ab", "1}[:ae"]
      tab("nil;:a").should == %w{:ab :ae}
    end

    it 'with special chars and custom search completes' do
      complete(:anywhere=>/(\$[^\s.]*)$/, :search=>false) {|e|
        global_variables.grep(/^#{Regexp.escape(e.matched[1])}/)
      }
      tab("$LO").should == ["$LOAD_PATH", "$LOADED_FEATURES"]
    end
  end

  it "default_mission set to a valid mission if irb doesn't exist" do
    Object.expects(:const_defined?).with(:IRB).returns(false)
    mission = Bond::Missions::DefaultMission.new
    mission.action.respond_to?(:call).should == true
  end
end
