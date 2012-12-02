require File.join(File.dirname(__FILE__), 'test_helper')

describe "ObjectMission" do
  before { Bond.agent.reset }
  describe "object mission" do
    it "with default action completes" do
      complete(:object=>"String")
      complete(:on=>/man/) { %w{upper upster upful}}
      tab("'man'.up").sort.should == [".upcase", ".upcase!", ".upto"]
    end

    it "with regex condition completes" do
      complete(:object=>'Str.*') {|e| e.object.class.superclass.instance_methods(true) }
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
      matches.size.should.be > 0
      matches.all? {|e| !e.include?('{')}.should == true
    end

    it "completes with additional text after completion point" do
      complete(:object=>"Object")
      tab(':man.f blah', ':man.f').include?(':man.freeze').should == true
    end

    it "doesn't evaluate anything before the completion object" do
      complete(:object=>'Object')
      tab('raise :man.i').size.should > 0
    end

    it "ignores invalid ruby" do
      complete(:object=>"String")
      tab("blah.upt").should == []
    end

    # needed to ensure Bond works in irbrc
    it "doesn't evaluate irb binding on definition" do
      Object.expects(:const_defined?).never
      complete(:object=>"String")
    end
  end
end