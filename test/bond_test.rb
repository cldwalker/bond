require File.join(File.dirname(__FILE__), 'test_helper')

class BondTest < Test::Unit::TestCase
  context "debrief" do
    test "prints error if readline_plugin is not a module" do
      capture_stderr { Bond.debrief :readline_plugin=>false }.should =~ /Invalid/
    end
    
    test "prints error if readline_plugin doesn't have all required methods" do
      capture_stderr {Bond.debrief :readline_plugin=>Module.new{ def setup; end } }.should =~ /Invalid/
    end

    test "no error if valid readline_plugin" do
      capture_stderr {Bond.debrief :readline_plugin=>Module.new{ def setup; end; def line_buffer; end } }.should == ''
    end
  end
end