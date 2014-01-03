require File.join(File.dirname(__FILE__), 'test_helper')

describe "M" do
  describe "#load_gems" do
    before { $: << '/dir' }
    after { $:.pop }

    def mock_file_exists(file)
      File.expects(:exist?).at_least(1).returns(false).with {|e| e != file }
      File.expects(:exist?).times(1).returns(true).with {|e| e == file }
    end

    it "loads gem" do
      M.expects(:gem)
      mock_file_exists '/dir/boom/../bond'
      M.expects(:load_dir).with('/dir/boom/../bond').returns(true)
      Bond.load_gems('boom').should == ['boom']
    end

    it "loads plugin gem in gem format" do
      M.expects(:find_gem_file).returns(false)
      mock_file_exists '/dir/boom/completions/what.rb'
      M.expects(:load_file).with('/dir/boom/completions/what.rb')
      Bond.load_gems('boom-what').should == ['boom-what']
    end

    it "loads plugin gem in file format" do
      M.expects(:find_gem_file).returns(false)
      mock_file_exists '/dir/boom/completions/what.rb'
      M.expects(:load_file).with('/dir/boom/completions/what.rb')
      Bond.load_gems('boom/what.rb').should == ['boom/what.rb']
    end
  end
end
