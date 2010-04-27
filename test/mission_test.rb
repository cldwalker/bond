require File.join(File.dirname(__FILE__), 'test_helper')

describe "Mission" do
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
      complete(:on=>/blah/) { 'blah' }
      tab('blah ').should == ['blah']
    end

    it "with symbol action completes" do
      Rc.module_eval %[def blah(input); %w{one two three}; end]
      complete(:on=>/blah/, :action=>:blah)
      tab('blah ').should == %w{one two three}
    end

    it "with string action completes" do
      Rc.module_eval %[def blah(input); %w{one two three}; end]
      complete(:on=>/blah/, :action=>'blah')
      tab('blah ').should == %w{one two three}
    end

    it "always passes Input to action block" do
      complete(:on=>/man/) {|e| e.should.be.is_a(Input); [] }
      tab('man ')
    end
  end

  it "sets binding to toplevel binding when not in irb" do
    Mission.eval_binding = nil
    mock_irb
    ::IRB.CurrentContext.expects(:workspace).raises
    Mission.eval_binding.should == ::TOPLEVEL_BINDING
  end
end
