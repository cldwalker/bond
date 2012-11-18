require File.join(File.dirname(__FILE__), 'test_helper')

describe "Completion" do
  before_all {
    reset
    M.load_file File.dirname(__FILE__) + '/../lib/bond/completion.rb'
    M.load_dir File.dirname(__FILE__) + '/../lib/bond'
  }

  it "completes global variables anywhere" do
    tab("blah $LOA").should.satisfy {|e|
      e.size > 0 && e.all? {|e| e=~ /^\$LOA/} }
    tab("h[$LOADED").should == ["h[$LOADED_FEATURES"]
  end

  it "completes absolute constants anywhere" do
    tab("blah ::Has").should == ["::Hash"]
    tab("h[::Has").should == ["h[::Hash"]
  end

  it "completes invalid constants safely" do
    capture_stdout {
      tab("Bond::MethodMission ").should == []
    }.should == ''
  end

  it "completes nested classes greater than 2 levels" do
    eval %[module ::Foo; module Bar; module Baz; end; end; end]
    tab("Foo::Bar::B").should == %w{Foo::Bar::Baz}
  end

  it "completes nested classes anywhere" do
    tab("module Blah; include Bond::Sea").should == ["Bond::Search"]
  end

  it "completes symbols anywhere" do
    Symbol.expects(:all_symbols).twice.returns([:mah])
    tab("blah :m").size.should.be > 0
    tab("blah[:m").should == ["blah[:mah"]
  end

  it "completes method arguments with parenthesis" do
    tab("%w{ab bc cd}.delete(").should == %w{ab bc cd}
  end

  it "completes method arguments when object contains method names" do
    tab("%w{find ab cd}.delete ").should == %w{find ab cd}
  end

  it "completes hash coming from a method" do
    tab('Bond.config[:r').should == ["Bond.config[:readline"]
  end

  it "methods don't swallow up default completion" do
    Bond.agent.find_mission("some_method(:verbose=>true) { Arr").should == nil
  end

  describe "completes object methods" do
    def be_methods_from(klass, regex, obj=klass.new)
      lambda {|e|
        meths = e.map {|f| f.sub(/^#{Regexp.quote(regex)}/, '') }
        meths.size.should.be > 0
        (meths - obj.methods.map {|e| e.to_s} - Mission::OPERATORS).size.should == 0
      }
    end

    shared "objects" do
      it "non whitespace object" do
        tab(':man.').should be_methods_from(Symbol, ':man.', :man)
      end

      it "nil" do
        tab("nil.t").should be_methods_from(NilClass, 'nil.', nil)
      end

      it "false" do
        tab("false.f").should be_methods_from(FalseClass, 'false.', false)
      end

      it "strings" do
        tab("'man oh'.s").should be_methods_from(String, '.')
        tab('"man oh".s').should be_methods_from(String, '.')
      end

      it "array" do
        tab("[1, 2].f").should be_methods_from(Array, '2].')
      end

      it "hash" do
        tab("{:a =>1}.f").should be_methods_from(Hash, '1}.')
      end

      it "regexp" do
        tab("/man oh/.c").should be_methods_from(Regexp, 'oh/.', /man oh/)
      end

      it "proc" do
        tab('lambda { }.c').should be_methods_from(Proc, '}.', lambda{})
        tab('proc { }.c').should be_methods_from(Proc, '}.', lambda{})
      end

      it "range" do
        tab("(1 .. 10).m").should be_methods_from(Range, '10).', (1..10))
      end

      it "object between ()" do
        tab("(2 * 2).").should be_methods_from(Fixnum, '2).', 2)
        tab("String.new('man oh').s").should be_methods_from(String, ').')
      end

      it "object quoted by {}" do
        tab("%r{man oh}.c").should be_methods_from(Regexp, 'oh}.', /man oh/)
        tab("%q{man oh}.s").should be_methods_from(String, 'oh}.')
        tab("%Q{man oh}.s").should be_methods_from(String, 'oh}.')
        tab("%w{man oh}.f").should be_methods_from(Array, 'oh}.')
        tab("%s{man oh}.t").should be_methods_from(Symbol, 'oh}.', :man)
        tab("%{man oh}.t").should be_methods_from(String, 'oh}.')
      end

      it "object quoted by []" do
        tab("%r[man oh].c").should be_methods_from(Regexp, 'oh].', /man oh/)
        tab("%q[man oh].s").should be_methods_from(String, 'oh].')
        tab("%Q[man oh].s").should be_methods_from(String, 'oh].')
        tab("%w[man oh].f").should be_methods_from(Array, 'oh].')
        tab("%s[man oh].t").should be_methods_from(Symbol, 'oh].', :man)
        tab("%[man oh].t").should be_methods_from(String, 'oh].')
      end

      it "with overridden class method" do
        complete :on=>/(.*)./, :object=>'Object'
        tab("obj = Object.new; def obj.class; end; obj.").should be_methods_from(Object, 'obj.')
      end
    end

    describe "for" do
      behaves_like "objects"
    end

    describe "after valid ruby for" do
      def tab(str)
        super("nil; "+str)
      end
      behaves_like "objects"
    end

    describe "after invalid ruby for" do
      def tab(str)
        super("blah "+str)
      end
      behaves_like "objects"
    end
  end
end
