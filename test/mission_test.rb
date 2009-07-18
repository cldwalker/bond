require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::MissionTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }

  context "mission" do
    before(:each) {|e| Bond.agent.instance_eval("@missions = []") }
    test "completes" do
      Bond.complete(:on=>/bling/) {|e| %w{ab cd fg hi}}
      Bond.complete(:method=>'cool') {|e| [] }
      complete('some bling f').should == %w{fg}
    end

    test "with method completes" do
      Bond.complete(:on=>/bling/) {|e| [] }
      Bond.complete(:method=>'cool') {|e| %w{ab cd ef gd} }
      complete('cool c').should == %w{cd}
    end

    test "with method and quoted argument completes" do
      Bond.complete(:on=>/bling/) {|e| [] }
      Bond.complete(:method=>'cool') {|e| %w{ab cd ef ad} }
      complete('cool "a').should == %w{ab ad}
    end

    test "with string method completes exact matches" do
      Bond.complete(:method=>'cool?') {|e| [] }
      Bond.complete(:method=>'cool') {|e| %w{ab cd ef gd} }
      complete('cool c').should == %w{cd}
    end

    test "with regex method completes multiple methods" do
      Bond.complete(:method=>/cool|ls/) {|e| %w{ab cd ef ad}}
      complete("cool a").should == %w{ab ad}
      complete("ls c").should == %w{cd}
    end

    test "with regexp condition completes" do
      Bond.complete(:on=>/\s*'([^']+)$/, :search=>false) {|e| %w{coco for puffs}.grep(/#{e.matched[1]}/) }
      complete("require 'ff").should == ['puffs']
    end

    test "with non-string completions completes" do
      Bond.complete(:on=>/.*/) { [:one,:two,:three] }
      complete('ok ').should == %w{one two three}
    end

    test "with symbol action completes" do
      eval %[module ::Bond::Actions; def blah(input); %w{one two three}; end; end]
      Bond.complete(:method=>'blah', :action=>:blah)
      complete('blah ').should == %w{one two three}
    end

    test "with invalid action prints error" do
      Bond.complete(:on=>/bling/) {|e| raise "whoops" }
      capture_stderr { complete('bling') }.should =~ /bling.*whoops/m
    end
  end

  test "default_mission set to a valid mission if irb doesn't exist" do
    Object.expects(:const_defined?).with(:IRB).returns(false)
    mission = Bond::Missions::DefaultMission.new
    mission.action.respond_to?(:call).should == true
  end
end
