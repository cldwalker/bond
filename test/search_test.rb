require File.join(File.dirname(__FILE__), 'test_helper')

describe "Search" do
  before_all { Bond.debrief(:readline_plugin=>valid_readline_plugin) }
  before { Bond.agent.reset }

  describe "mission with search" do
    it "false completes" do
      complete(:on=>/cool '(.*)/, :search=>false) {|e| %w{coco for puffs}.grep(/#{e.matched[1]}/) }
      tab("cool 'ff").should == ['puffs']
    end
    
    it "proc completes" do
      complete(:on=>/blah/, :search=>proc {|input, list| list.grep(/#{input}/)}) {|e| %w{coco for puffs} }
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
      tab("blah b-t").should == ['big_two']
    end
  end

  it "underscore search doesn't pick up strings starting with __" do
    completions = ["include?", "instance_variable_defined?", "__id__", "include_and_exclude?"]
    complete(:on=>/blah/, :search=>:underscore) { completions }
    tab("blah i").should == ["include?", "instance_variable_defined?", "include_and_exclude?"]
  end

  it "underscore search can match first unique strings of each underscored word" do
    completions = %w{so_long so_larger so_louder}
    complete(:on=>/blah/, :search=>:underscore) { completions }
    tab("blah s-lo").should == %w{so_long so_louder}
    tab("blah s-lou").should == %w{so_louder}
  end

  it "search handles completions with regex characters" do
    completions = ['[doh]', '.*a', '?ok']
    complete(:on=>/blah/) { completions }
    tab('blah .').should == ['.*a']
    tab('blah [').should == ['[doh]']
    tab('blah ?').should == ['?ok']
  end
end