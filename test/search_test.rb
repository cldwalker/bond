require File.join(File.dirname(__FILE__), 'test_helper')

describe "Search" do
  before { Bond.agent.reset }

  describe "mission with search" do
    it "false completes" do
      complete(:on=>/cool '(.*)/, :search=>false) {|e| %w{coco for puffs}.grep(/#{e.matched[1]}/) }
      tab("cool 'ff").should == ['puffs']
    end
    
    it "defined in Rc completes" do
      Rc.module_eval %q{def coco_search(input, list); list.grep(/#{input}/); end }
      complete(:on=>/blah/, :search=>:coco) {|e| %w{coco for puffs} }
      tab("blah ff").should == ['puffs']
    end

    it ":anywhere completes" do
      complete(:on=>/blah/, :search=>:anywhere) {|e| %w{coco for puffs} }
      tab("blah ff").should == ['puffs']
    end

    it ":ignore_case completes" do
      complete(:on=>/blah/, :search=>:ignore_case) {|e| %w{Coco For PufFs} }
      tab("blah pu").should == ['PufFs']
    end

    it ":underscore completes" do
      complete(:on=>/blah/, :search=>:underscore) {|e| %w{and_one big_two can_three} }
      tab("blah and").should == ['and_one']
      tab("blah b_t").should == ['big_two']
    end
  end

  it "underscore search doesn't pick up strings starting with __" do
    completions = ["include?", "instance_variable_defined?", "__id__", "include_and_exclude?"]
    complete(:on=>/blah/, :search=>:underscore) { completions }
    tab("blah i").should == ["include?", "instance_variable_defined?", "include_and_exclude?"]
  end

  it "underscore search autocompletes strings starting with __" do
    completions = ["include?", "__id__", "__send__"]
    complete(:on=>/blah/, :search=>:underscore) { completions }
    tab('blah _').should == ["__id__", "__send__"]
    tab('blah __').should == ["__id__", "__send__"]
    tab('blah __i').should == ["__id__"]
  end

  it "underscore search can match first unique strings of each underscored word" do
    completions = %w{so_long so_larger so_louder}
    complete(:on=>/blah/, :search=>:underscore) { completions }
    tab("blah s_lo").should == %w{so_long so_louder}
    tab("blah s_lou").should == %w{so_louder}
  end

  it "underscore search acts normal if ending in underscore" do
    complete(:on=>/blah/, :search=>:underscore) {|e| %w{and_one big_two can_three ander_one} }
    tab("blah and_").should == %w{and_one}
  end

  it "search handles completions with regex characters" do
    completions = ['[doh]', '.*a', '?ok']
    complete(:on=>/blah/) { completions }
    tab('blah .').should == ['.*a']
    tab('blah [').should == ['[doh]']
    tab('blah ?').should == ['?ok']
  end

  it "default search uses default search" do
    Search.default_search.should == :underscore
    Rc.expects(:underscore_search).with('a', %w{ab cd})
    Rc.send(:default_search, 'a', %w{ab cd})
  end

  describe "modules search" do
    before {
      complete(:on=>/blah/, :search=>:modules) { %w{A1 M1::Z M1::Y::X M2::X} }
    }
    it "completes all modules" do
      tab('blah ').should == ["A1", "M1::", "M2::"]
    end

    it "completes single first level module" do
      tab('blah A').should == %w{A1}
    end

    it "completes single first level module parent" do
      tab('blah M2').should == %w{M2::}
    end

    it "completes all second level modules" do
      tab('blah M1::').should == %w{M1::Z M1::Y::}
    end

    it "completes second level module parent" do
      tab('blah M1::Y').should == %w{M1::Y::}
    end

    it "completes third level module" do
      tab('blah M1::Y::').should == %w{M1::Y::X}
    end
  end

  describe "files search" do
    before {
      complete(:on=>/rm/, :search=>:files) { %w{a1 d1/f2 d1/d2/f1 d2/f1 d2/f1/ /f1} }
    }
    it "completes all paths" do
      tab('rm ').should == %w{a1 d1/ d2/ /}
    end

    it "completes single first level file" do
      tab('rm a').should == %w{a1}
    end

    it "completes single first level directory" do
      tab('rm d2').should == %w{d2/}
    end

    it "completes all second level paths" do
      tab('rm d1/').should == %w{d1/f2 d1/d2/}
    end

    it "completes single second level directory" do
      tab('rm d1/d2').should == %w{d1/d2/}
    end

    it "completes single third level file" do
      tab('rm d1/d2/').should == %w{d1/d2/f1}
    end

    it "completes file and directory with same name" do
      tab('rm d2/f').should == %w{d2/f1 d2/f1/}
    end

    it "completes file with full path" do
      tab('rm /f').should == %w{/f1}
    end
  end
end