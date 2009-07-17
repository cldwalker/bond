require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::ObjectMissionTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }
  before(:each) {|e| Bond.agent.instance_eval("@missions = []") }
  context "object mission" do
    test "with default action completes" do
      Bond.complete(:object=>"String")
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.u").should == ["'man'.upcase!", "'man'.unpack", "'man'.untaint", "'man'.upcase", "'man'.upto"]
    end

    test "with regex condition completes" do
      Bond.complete(:object=>/Str/) {|e| e.object.class.superclass.instance_methods(true) }
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.u").should == ["'man'.untaint"]
    end

    test "with explicit action completes" do
      Bond.complete(:object=>"String") {|e| e.object.class.superclass.instance_methods(true) }
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.u").should == ["'man'.untaint"]
    end

    test "ignores invalid invalid ruby" do
      Bond.complete(:object=>"String")
      complete("blah.upt").should == []
    end

    # needed to ensure Bond works in irbrc
    test "doesn't evaluate irb binding on definition" do
      Object.expects(:const_defined?).never
      Bond.complete(:object=>"String")
    end
  end
end