require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::MissionTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }

  context "mission" do
    before(:each) {|e| Bond.agent.instance_eval("@missions = []") }
    test "completes" do
      Bond.complete(:on=>/bling/) {|e,m| %w{ab cd fg hi}}
      Bond.complete(:command=>'cool') {|e,m| }
      complete('some bling f', 'f').should == %w{fg}
    end

    test "with command completes" do
      Bond.complete(:on=>/bling/) {|e,m| [] }
      Bond.complete(:command=>'cool') {|e,m| %w{ab cd ef gd} }
      complete('cool c', 'c').should == %w{cd}
    end

    test "with quoted command completes" do
      Bond.complete(:on=>/bling/) {|e,m| [] }
      Bond.complete(:command=>'cool') {|e,m| %w{ab cd ef ad} }
      complete('cool "a', 'a').should == %w{ab ad}
    end

    test "with no search option and matching completes" do
      Bond.complete(:on=>/\s*'([^']+)$/, :search=>false) {|e,m| %w{coco for puffs}.grep(/#{m[1]}/) }
      complete("require 'co", "co").should == ['coco']
    end

    test "with underscore search completes" do
      Bond.complete(:on=>/blah/, :search=>:underscore) {|e,m| %w{and_one big_two can_three} }
      complete("blah and").should == ['and_one']
      complete("blah b-t").should == ['big_two']
    end

    test "with object completes" do
      Bond.complete(:object=>"String")
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.upt").should == ["'man'.upto"]
    end

    test "ignores invalid objects" do
      Bond.complete(:object=>"String")
      complete("blah.upt").should == []
    end
  end
end