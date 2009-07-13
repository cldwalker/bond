require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::AgentTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>Module.new{ def setup; end; def line_buffer; end }) }

  context "InvalidAgent" do
    test "prints error if no action given for mission" do
      capture_stderr { Bond.complete :on=>/blah/ }.should =~ /Invalid mission/
    end

    test "prints error if no condition given" do
      capture_stderr { Bond.complete {|e,m| []} }.should =~ /Invalid mission/
    end
  
    test "prints error if invalid condition given" do
      capture_stderr { Bond.complete(:on=>'blah') {|e,m| []} }.should =~ /Invalid mission/
    end
    
    test "prints error if setting mission fails unpredictably" do
      Bond.agent.expects(:complete).raises(ArgumentError)
      capture_stderr { Bond.complete(:on=>/blah/) {|e,m| [] } }.should =~ /Mission setup failed/
    end
  end

  context "Agent" do
    before(:all) {|e| eval "module ::IRB; module InputCompletor; CompletionProc = lambda {|e| e.to_sym }; end ;end" }
    before(:each) {|e| Bond.agent.instance_eval("@missions = []") }

    def complete(full_line, last_word=full_line)
      Bond.agent.stubs(:line_buffer).returns(full_line)
      Bond.agent.call(last_word)
    end

    test "chooses default mission if no missions match" do
      Bond.complete(:on=>/bling/) {|e,m| [] }
      complete 'blah'
      Bond.agent.default_mission.default.should == true
    end

    test "chooses default mission if mission processing fails" do
      Bond.agent.expects(:find_mission).raises
      complete('blah')
      Bond.agent.default_mission.default.should == true
    end

    test "chooses on mission" do
      Bond.complete(:on=>/bling/) {|e,m| %w{ab cd fg hi}}
      Bond.complete(:command=>'cool') {|e,m| }
      complete('some bling f', 'f').should == %w{fg}
    end

    test "chooses command mission" do
      Bond.complete(:on=>/bling/) {|e,m| [] }
      Bond.complete(:command=>'cool') {|e,m| %w{ab cd ef gd} }
      complete('cool c', 'c').should == %w{cd}
    end

    test "chooses quoted command mission" do
      Bond.complete(:on=>/bling/) {|e,m| [] }
      Bond.complete(:command=>'cool') {|e,m| %w{ab cd ef ad} }
      complete('cool "a', 'a').should == %w{ab ad}
    end

    test "chooses mission which uses match and no search option" do
      Bond.complete(:on=>/\s*'([^']+)$/, :search=>false) {|e,m| %w{coco for puffs}.grep(/#{m[1]}/) }
      complete("require 'co", "co").should == ['coco']
    end

    test "chooses mission with underscore search" do
      Bond.complete(:on=>/blah/, :search=>:underscore) {|e,m| %w{and_one big_two can_three} }
      complete("blah and").should == ['and_one']
      complete("blah b-t").should == ['big_two']
    end
  end

  test "default_mission set to a valid mission if irb doesn't exist" do
    Object.expects(:const_defined?).with(:IRB).returns(false)
    Bond.agent.default_mission.is_a?(Bond::Mission).should == true
    Bond.agent.default_mission.action.respond_to?(:call).should == true
  end
end
