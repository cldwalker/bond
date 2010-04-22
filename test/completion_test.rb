require File.join(File.dirname(__FILE__), 'test_helper')

describe "Completion" do
  before_all { Bond.reset; Bond.debrief(:readline_plugin=>valid_readline_plugin)
    Bond::Rc.load File.dirname(__FILE__) + '/../lib/bond/completion.rb'
    Bond::MethodMission.actions = {}
  }

  it "completes global variables anywhere" do
    tab("blah $LOA").should.satisfy {|e|
      e.size > 0 && e.all? {|e| e=~ /^\$LOA/} }
    tab("h[$LOAD_").should == ["h[$LOAD_PATH"]
  end

  it "completes absolute constants anywhere" do
    tab("blah ::Arr").should == ["::Array"]
    tab("h[::Arr").should == ["h[::Array"]
  end

  it "completes invalid constants safely" do
    Bond.config[:debug] = true
    capture_stdout {
      tab("Bond::MethodMission ").should == []
    }.should == ''
    Bond.config[:debug] = false
  end

  it "completes nested classes anywhere" do
    mock_irb
    tab("blah IRB::In").should == ["IRB::InputCompletor"]
  end

  it "completes symbols anywhere" do
    Symbol.expects(:all_symbols).twice.returns([:mah])
    tab("blah :m").size.should.be > 0
    tab("blah[:m").should == ["blah[:mah"]
  end

  it "methods don't swallow up default completion" do
    Bond.agent.find_mission("Bond.complete(:method=>'blah') { Arr").should == nil
  end

  describe "completes object methods" do
    def have_methods_from(klass, regex)
      lambda {|e|
        meths = e.map {|f| f.sub(/^#{Regexp.quote(regex)}/, '') }
        (meths & klass.instance_methods(false).map {|g| g.to_s }).size.should.be > 0
      }
    end

    it "anywhere" do
      tab("blah :man.").should have_methods_from(Symbol, ':man.')
    end

    it "anywhere for string method" do
      tab("blah 'man'.s").should have_methods_from(String, '.')
    end

    describe "for" do
      it "hash" do
        tab("{:a =>1}.f").should have_methods_from(Hash, '1}.')
      end

      it "array" do
        tab("[1, 2].f").should have_methods_from(Array, '2].')
      end

      it "strings" do
        tab("'man oh'.s").should have_methods_from(String, '.')
        tab('"man oh".s').should have_methods_from(String, '.')
      end

      it "nil" do
        tab("nil.t").should have_methods_from(NilClass, 'nil.')
      end

      it "false" do
        tab("false.f").should have_methods_from(FalseClass, 'false.')
      end

      it "proc" do
        tab('lambda { }.c').should have_methods_from(Proc, '}.')
      end

      it "range" do
        tab("(1 .. 10).f").should have_methods_from(Range, '10).')
      end

      it "regexp" do
        tab("/man oh/.c").should have_methods_from(Regexp, 'oh/.')
      end

      it "anything quoted with {}" do
        tab("%r{man oh}.c").should have_methods_from(Regexp, 'oh}.')
        tab("%q{man oh}.s").should have_methods_from(String, 'oh}.')
        tab("%w{man oh}.f").should have_methods_from(Array, 'oh}.')
        tab("%s{man oh}.t").should have_methods_from(Symbol, 'oh}.')
      end

      it "anything quoted with []" do
        tab("%r[man oh].c").should have_methods_from(Regexp, 'oh].')
        tab("%q[man oh].s").should have_methods_from(String, 'oh].')
        tab("%w[man oh].f").should have_methods_from(Array, 'oh].')
        tab("%s[man oh].t").should have_methods_from(Symbol, 'oh].')
      end

      it "any expression between ()" do
        tab("(2 * 2).").should have_methods_from(Fixnum, '2).')
        tab("String.new('man oh').s").should have_methods_from(String, ').')
      end
    end
  end
end