require File.join(File.dirname(__FILE__), 'test_helper')

describe "ObjectMission" do
  before_all { Bond.debrief(:readline_plugin=>valid_readline_plugin) }
  before { Bond.agent.reset }
  describe "object mission" do
    it "with default action completes" do
      complete(:object=>"String")
      complete(:on=>/man/) { %w{upper upster upful}}
      tab("'man'.up").sort.should == [".upcase", ".upcase!", ".upto"]
    end

    it "with regex condition completes" do
      complete(:object=>/Str/) {|e| e.object.class.superclass.instance_methods(true) }
      complete(:on=>/man/) { %w{upper upster upful}}
      tab("'man'.unta").should == [".untaint"]
    end

    it "with explicit action completes" do
      complete(:object=>"String") {|e| e.object.class.superclass.instance_methods(true) }
      complete(:on=>/man/) { %w{upper upster upful}}
      tab("'man'.unta").should == [".untaint"]
    end

    it "completes without including word break characters" do
      complete(:object=>"Hash")
      matches = tab("{}.f")
      assert matches.size > 0
      matches.all? {|e| !e.include?('{')}.should == true
    end

    it "completes nil, false and range objects" do
      complete(:object=>"Object")
      tab("nil.f").size.should.be > 0
      tab("false.f").size.should.be > 0
      tab("(1..10).f").size.should.be > 0
    end

    it "completes hashes and arrays with spaces" do
      complete(:object=>"Object")
      tab("[1, 2].f").size.should.be > 0
      tab("{:a =>1}.f").size.should.be > 0
    end

    it "ignores invalid invalid ruby" do
      complete(:object=>"String")
      tab("blah.upt").should == []
    end

    it "ignores object that doesn't have a valid class" do
      Bond.config[:debug] = true
      complete :on=>/(.*)./, :object=>'Object'
      capture_stdout {
        tab("obj = Object.new; def obj.class; end; obj.").should == []
      }.should == ''
      Bond.config[:debug] = false
    end

    it "always passes string to action block" do
      complete(:on=>/(.*)./, :object=>'Object') {|e| e.should.be.is_a(String); [] }
      tab('"man".')
    end

    # needed to ensure Bond works in irbrc
    it "doesn't evaluate irb binding on definition" do
      Object.expects(:const_defined?).never
      complete(:object=>"String")
    end

    it "sets binding to toplevel binding when not in irb" do
      Object.expects(:const_defined?).with(:IRB).returns(false)
      mission = Bond::Mission.create(:object=>'Symbol')
      mission.class.expects(:eval).with(anything, ::TOPLEVEL_BINDING)
      mission.matches?(':ok.')
    end
  end
end