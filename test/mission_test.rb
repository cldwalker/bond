require File.join(File.dirname(__FILE__), 'test_helper')

describe "Mission" do
  before_all { Bond.debrief(:readline_plugin=>valid_readline_plugin) }

  describe "mission" do
    before { Bond.agent.reset }
    it "completes" do
      complete(:on=>/bling/) {|e| %w{ab cd fg hi}}
      complete(:method=>'cool') {|e| [] }
      tabtab('some bling f').should == %w{fg}
    end

    it "with method completes" do
      complete(:on=>/bling/) {|e| [] }
      complete(:method=>'cool') {|e| %w{ab cd ef gd} }
      tabtab('cool c').should == %w{cd}
    end

    it "with method and quoted argument completes" do
      complete(:on=>/bling/) {|e| [] }
      complete(:method=>'cool') {|e| %w{ab cd ef ad} }
      tabtab('cool "a').should == %w{ab ad}
    end

    it "with string method completes exact matches" do
      complete(:method=>'cool?') {|e| [] }
      complete(:method=>'cool') {|e| %w{ab cd ef gd} }
      tabtab('cool c').should == %w{cd}
    end

    it "with regex method completes multiple methods" do
      complete(:method=>/cool|ls/) {|e| %w{ab cd ef ad}}
      tabtab("cool a").should == %w{ab ad}
      tabtab("ls c").should == %w{cd}
    end

    it "with regexp condition completes" do
      complete(:on=>/\s*'([^']+)$/, :search=>false) {|e| %w{coco for puffs}.grep(/#{e.matched[1]}/) }
      tabtab("require 'ff").should == ['puffs']
    end

    it "with non-string completions completes" do
      complete(:on=>/.*/) { [:one,:two,:three] }
      tabtab('ok ').should == %w{one two three}
    end

    it "with non-array completions completes" do
      complete(:method=>'blah') { 'blah' }
      tabtab('blah ').should == ['blah']
    end

    it "with symbol action completes" do
      eval %[module ::Bond::Actions; def blah(input); %w{one two three}; end; end]
      complete(:method=>'blah', :action=>:blah)
      tabtab('blah ').should == %w{one two three}
    end

    it "with invalid action prints error" do
      complete(:on=>/bling/) {|e| raise "whoops" }
      capture_stderr { tabtab('bling') }.should =~ /bling.*whoops/m
    end

    it "always passes string to action block" do
      complete(:on=>/man/) {|e| e.should.be.is_a(String); [] }
      tabtab('man ')
    end
  end

  it "default_mission set to a valid mission if irb doesn't exist" do
    Object.expects(:const_defined?).with(:IRB).returns(false)
    mission = Bond::Missions::DefaultMission.new
    mission.action.respond_to?(:call).should == true
  end
end
