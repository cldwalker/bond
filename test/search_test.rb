require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::SearchTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }
  before(:each) {|e| Bond.agent.instance_eval("@missions = []") }

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
end