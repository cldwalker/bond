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
      complete(:method=>'blah') { 'blah' }
      tab('blah ').should == ['blah']
    end

    it "with symbol action completes" do
      eval %[module ::Bond::Actions; def blah(input); %w{one two three}; end; end]
      complete(:method=>'blah', :action=>:blah)
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

  describe "method mission" do
    before { Bond.agent.reset }

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

    it "with regex method completes for multiple methods" do
      complete(:method=>/cool|ls/) {|e| %w{ab cd ef ad}}
      tab("cool a").should == %w{ab ad}
      tab("ls c").should == %w{cd}
    end
  end

  it "default_mission set to a valid mission if irb doesn't exist" do
    Object.expects(:const_defined?).with(:IRB).returns(false)
    mission = Bond::Missions::DefaultMission.new
    mission.action.respond_to?(:call).should == true
  end
end
