require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::ObjectMissionTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }
  before(:each) {|e| Bond.agent.reset }
  context "object mission" do
    test "with default action completes" do
      complete(:object=>"String")
      complete(:on=>/man/) { %w{upper upster upful}}
      tabtab("'man'.u").should == [".upcase!", ".unpack", ".untaint", ".upcase", ".upto"]
    end

    test "with regex condition completes" do
      complete(:object=>/Str/) {|e| e.object.class.superclass.instance_methods(true) }
      complete(:on=>/man/) { %w{upper upster upful}}
      tabtab("'man'.u").should == [".untaint"]
    end

    test "with explicit action completes" do
      complete(:object=>"String") {|e| e.object.class.superclass.instance_methods(true) }
      complete(:on=>/man/) { %w{upper upster upful}}
      tabtab("'man'.u").should == [".untaint"]
    end

    test "completes without including word break characters" do
      complete(:object=>"Hash")
      matches = tabtab("{}.f")
      assert matches.size > 0
      matches.all? {|e| !e.include?('{')}.should == true
    end

    test "completes nil, false and range objects" do
      complete(:object=>"Object")
      assert tabtab("nil.f").size > 0
      assert tabtab("false.f").size > 0
      assert tabtab("(1..10).f").size > 0
    end

    test "completes hashes and arrays with spaces" do
      complete(:object=>"Object")
      assert tabtab("[1, 2].f").size > 0
      assert tabtab("{:a =>1}.f").size > 0
    end

    test "ignores invalid invalid ruby" do
      complete(:object=>"String")
      tabtab("blah.upt").should == []
    end

    # needed to ensure Bond works in irbrc
    test "doesn't evaluate irb binding on definition" do
      Object.expects(:const_defined?).never
      complete(:object=>"String")
    end

    test "sets binding to toplevel binding when not in irb" do
      Object.expects(:const_defined?).with(:IRB).returns(false)
      mission = Bond::Mission.create(:object=>'Symbol')
      mission.class.expects(:eval).with(anything, ::TOPLEVEL_BINDING)
      mission.matches?(':ok.')
    end
  end
end