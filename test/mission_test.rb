require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::MissionTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }

  context "mission" do
    before(:each) {|e| Bond.agent.instance_eval("@missions = []") }
    test "completes" do
      Bond.complete(:on=>/bling/) {|e| %w{ab cd fg hi}}
      Bond.complete(:method=>'cool') {|e| [] }
      complete('some bling f', 'f').should == %w{fg}
    end

    test "with method completes" do
      Bond.complete(:on=>/bling/) {|e| [] }
      Bond.complete(:method=>'cool') {|e| %w{ab cd ef gd} }
      complete('cool c', 'c').should == %w{cd}
    end

    test "with quoted method completes" do
      Bond.complete(:on=>/bling/) {|e| [] }
      Bond.complete(:method=>'cool') {|e| %w{ab cd ef ad} }
      complete('cool "a', 'a').should == %w{ab ad}
    end

    test "with string method completes exact matches" do
      Bond.complete(:method=>'cool?') {|e| [] }
      Bond.complete(:method=>'cool') {|e| %w{ab cd ef gd} }
      complete('cool c', 'c').should == %w{cd}
    end

    test "with regex method completes multiple methods" do
      Bond.complete(:method=>/cool|ls/) {|e| %w{ab cd ef ad}}
      complete("cool a").should == %w{ab ad}
      complete("ls c").should == %w{cd}
    end

    test "with no search option and matching completes" do
      Bond.complete(:on=>/\s*'([^']+)$/, :search=>false) {|e| %w{coco for puffs}.grep(/#{e.matched[1]}/) }
      complete("require 'co", "co").should == ['coco']
    end

    test "with underscore search completes" do
      Bond.complete(:on=>/blah/, :search=>:underscore) {|e| %w{and_one big_two can_three} }
      complete("blah and").should == ['and_one']
      complete("blah b-t").should == ['big_two']
    end

    test "with object and default action completes" do
      Bond.complete(:object=>"String")
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.u").should == ["'man'.upcase!", "'man'.unpack", "'man'.untaint", "'man'.upcase", "'man'.upto"]
    end

    test "with regex object completes" do
      Bond.complete(:object=>/Str/) {|e| e.object.class.superclass.instance_methods(true) }
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.u").should == ["'man'.untaint"]
    end

    test "with object and explicit action completes" do
      Bond.complete(:object=>"String") {|e| e.object.class.superclass.instance_methods(true) }
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.u").should == ["'man'.untaint"]
    end

    test "ignores invalid objects" do
      Bond.complete(:object=>"String")
      complete("blah.upt").should == []
    end
  end
end
