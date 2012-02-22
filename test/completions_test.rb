require File.join(File.dirname(__FILE__), 'test_helper')

describe "completions for" do
  before_all {
    reset
    complete(:all_methods=>true)
    complete(:all_operator_methods=>true)
    M.load_file File.dirname(__FILE__) + '/../lib/bond/completion.rb'
    M.load_dir File.dirname(__FILE__) + '/../lib/bond'
  }

  it "Array#delete" do
    tab("[12,23,34,15].delete 1").should == %w{12 15}
  end

  describe "Hash" do
    before { @hash = %q{{:ab=>1,:bc=>1,:cd=>3,:ae=>2}} }

    it "#delete" do
      tab("#{@hash}.delete :a").sort.should == %w{:ab :ae}
    end

    it "#index" do
      tab("#{@hash}.index 2").should == %w{2}
    end

    it "#[]" do
      tab("#{@hash}['a").sort.should == %w{ab ae}
    end
  end

  describe "Kernel" do
    it "#raise" do
      tab("raise Errno::ETIME").sort.should == %w{Errno::ETIME Errno::ETIMEDOUT}
    end

    it "#require" do
      mock_libs = ['net/http.rb', 'net/http/get.rb', 'abbrev.rb'].map {|e| $:[0] + "/#{e}" }
      Dir.stubs(:[]).returns(mock_libs)
      tab("require 'net/htt").should == %w{net/http.rb net/http/}
    end
  end

  describe "Object" do
    it "#instance_of?" do
      expectations = ['Hash']
      expectations = ["Hash", "Hash::"] if RbConfig::CONFIG["RUBY_SO_NAME"].to_s[/rubinius/i]
      tab("[].instance_of? Has").should == expectations
    end

    it "#is_a?" do
      tab("Module.is_a? Mod").should == ['Module']
    end

    it "#send" do
      tab("Object.send :ne").should == [':new']
    end

    it "#send and additional arguments" do
      tab('Bond.send :const_get, Ag').should == ['Agent']
    end

    it "#send and invalid first argument" do
      tab('Bond.send :blah, ').should == []
    end

    it "#instance_variable_get" do
      tab("Bond::M.instance_variable_get '@a").should == ['@agent']
    end

    it "#method" do
      tab("Bond::M.method :ho").should == [':home']
    end

    it "#[]" do
      ::ENV['ZZZ'] = ::ENV['ZZY'] = 'blah'
      tab("ENV['ZZ").should == %w{ZZY ZZZ}
    end
  end

  describe "Module" do
    it "#const_get" do
      tab("Bond.const_get M").sort.should == ['M', 'MethodMission', 'Mission']
    end

    it "#instance_methods" do
      tab("Bond::Agent.instance_method :ca").should == [':call']
    end

    it "#>" do
      tab("Object > Mod").should == %w{Module}
    end

    it "#> and :files search" do
      tab("Object > Bon").should == %w{Bond Bond::}
    end
  end
end
