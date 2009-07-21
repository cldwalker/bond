require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::SearchTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }
  before(:each) {|e| Bond.agent.reset }

  context "mission with search" do
    test "false completes" do
      Bond.complete(:on=>/cool '(.*)/, :search=>false) {|e| %w{coco for puffs}.grep(/#{e.matched[1]}/) }
      complete("cool 'ff").should == ['puffs']
    end
    
    test "proc completes" do
      Bond.complete(:method=>'blah', :search=>proc {|input, list| list.grep(/#{input}/)}) {|e| %w{coco for puffs} }
      complete("blah 'ff").should == ['puffs']
    end

    test ":anywhere completes" do
      Bond.complete(:method=>'blah', :search=>:anywhere) {|e| %w{coco for puffs} }
      complete("blah 'ff").should == ['puffs']
    end

    test ":ignore_case completes" do
      Bond.complete(:method=>'blah', :search=>:ignore_case) {|e| %w{Coco For PufFs} }
      complete("blah 'pu").should == ['PufFs']
    end

    test ":underscore completes" do
      Bond.complete(:on=>/blah/, :search=>:underscore) {|e| %w{and_one big_two can_three} }
      complete("blah and").should == ['and_one']
      complete("blah b-t").should == ['big_two']
    end
  end

  test "underscore search doesn't pick up strings starting with __" do
    completions = ["include?", "instance_variable_defined?", "__id__", "include_and_exclude?"]
    Bond.complete(:method=>'blah', :search=>:underscore) { completions }
    complete("blah i").should == ["include?", "instance_variable_defined?", "include_and_exclude?"]
  end

  test "underscore search can match first unique strings of each underscored word" do
    completions = %w{so_long so_larger so_louder}
    Bond.complete(:method=>'blah', :search=>:underscore) { completions }
    complete("blah s-lo").should == %w{so_long so_louder}
    complete("blah s-lou").should == %w{so_louder}
  end

  test "search handles completions with regex characters" do
    completions = ['[doh]', '.*a', '?ok']
    Bond.complete(:on=>/blah/) { completions }
    complete('blah .').should == ['.*a']
    complete('blah [').should == ['[doh]']
    complete('blah ?').should == ['?ok']
  end
end