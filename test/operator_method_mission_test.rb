require File.join(File.dirname(__FILE__), 'test_helper')

describe "operator method mission" do
  before_all {
    Bond.debrief(:readline_plugin=>valid_readline_plugin)
    Bond::MethodMission.actions = {}
    Bond::MethodMission.class_actions = {}
  }
  before { Bond.agent.reset; Bond.complete(:all_operator_methods=>true) }

  it "completes" do
    complete(:method=>"Hash#*") { %w{ab cd ae} }
    tab('{:a=>1} * a').should == %w{ab ae}
    tab('{:a=>1} *').should == %w{ab cd ae}
  end

  it "for :[] completes" do
    complete(:method=>"Hash#[]") { %w{ab cd ae} }
    tab('{:a=>1}["a').should == %w{ab ae}
  end
end