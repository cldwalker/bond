require File.join(File.dirname(__FILE__), 'test_helper')

describe "Agent" do
  describe "#call" do
    before { Bond.agent.reset }

    it "chooses default mission if no missions match" do
      complete(:on=>/bling/) {|e| [] }
      Bond.agent.default_mission.expects(:execute).with {|e| e.is_a?(Bond::Input) }
      tab 'blah'
    end

    it "for internal Bond error completes error" do
      complete(:on=>/bling/) {|e| [] }
      Bond.agent.expects(:find_mission).raises('wtf')
      errors = tab('bling')
      errors[0].should =~ /Bond Error: Failed internally.*'wtf'/
      errors[1].should =~ /Please/
    end

    def complete_error(msg)
      lambda {|e|
        e[0].should =~ msg
        e[1].should =~ /Completion Info: Matches.*blah/
      }
    end

    it "for completion action raising error completes error" do
      Bond.config[:debug] = false
      complete(:on=>/blah/) { raise 'blah' }
      errors = tab('blah')
      errors.size.should == 2
      errors.should complete_error(/Bond Error: Failed.*action.*'blah'/)
      Bond.config[:debug] = true
    end

    it "for completion action raising error with debug completes error and stacktrace" do
      complete(:on=>/blah/) { raise 'blah' }
      errors = tab('blah')
      errors.size.should == 3
      errors.should complete_error(/Bond Error: Failed.*action.*'blah'/)
      errors[2].should =~ /Stack Trace:/
    end

    it "for completion action raising SyntaxError in eval completes error" do
      complete(:on=>/blah/) { eval '{[}'}
      tab('blah').should complete_error(/Bond Error: Failed.*action.*(eval)/)
    end

    it "for completion action that doesn't exist completes error" do
      complete(:on=>/blah/, :action=>:huh)
      tab('blah').should complete_error(/Bond Error:.*action 'huh' doesn't exist/)
    end

    it "for completion search raising error completes error" do
      Rc.module_eval "def blah_search(*args); raise 'blah'; end"
      complete(:on=>/blah/, :search=>:blah) { [1] }
      tab('blah').should complete_error(/Bond Error: Failed.*search.*'blah'/)
    end

    it "for completion search that doesn't exist completes error" do
      complete(:on=>/blah/, :search=>:huh) { [] }
      tab('blah').should complete_error(/Bond Error:.*search 'huh' doesn't exist/)
    end
  end

  describe "complete" do
    before {|e| Bond.agent.reset }
    it "with no :action prints error" do
      capture_stderr { complete :on=>/blah/ }.should =~ /Invalid :action/
    end

    it "with no :on prints error" do
      capture_stderr { complete {|e| []} }.should =~ /Invalid :on/
    end

    it "with invalid :on prints error" do
      capture_stderr { complete(:on=>'blah') {|e| []} }.should =~ /Invalid :on/
    end

    it "with internal failure prints error" do
      Mission.expects(:create).raises(RuntimeError, 'blah')
      capture_stderr { complete(:on=>/blah/) {|e| [] } }.should =~ /Unexpected error.*blah/
    end

    it "with invalid :anywhere and :prefix prints no error" do
      capture_stderr { complete(:prefix=>nil, :anywhere=>:blah) {} }.should == ''
    end

    it "with invalid :object prints no error" do
      capture_stderr { complete(:object=>:Mod) {} }.should == ''
    end

    it "with invalid :method prints error" do
      capture_stderr { complete(:method=>true) {} }.should =~ /Invalid :method\(s\)/
    end

    it "with invalid :methods prints error" do
      capture_stderr { complete(:methods=>[:blah]) {} }.should =~ /Invalid :method\(s\)/
    end

    it "with invalid :class prints no error" do
      capture_stderr { complete(:method=>'ok', :class=>/wtf/) {} }.should == ''
    end

    it "places missions last when declared last" do
      complete(:object=>"Symbol", :place=>:last)
      complete(:on=>/man/, :place=>:last) { }
      complete(:on=>/man\s*(.*)/) {|e| [e.matched[1]] }
      Bond.agent.missions.map {|e| e.class}.should == [Mission, ObjectMission, Mission]
      tab('man ok').should == ['ok']
    end

    it "places mission correctly for a place number" do
      complete(:object=>"Symbol")
      complete(:on=>/man/) {}
      complete(:on=>/man\s*(.*)/, :place=>1) {|e| [e.matched[1]] }
      tab('man ok')
      Bond.agent.missions.map {|e| e.class}.should == [Mission, ObjectMission, Mission]
      tab('man ok').should == ['ok']
    end
  end

  describe "recomplete" do
    before {|e| Bond.agent.reset }

    it "recompletes a mission" do
      complete(:on=>/man/) { %w{1 2 3}}
      Bond.recomplete(:on=>/man/) { %w{4 5 6}}
      tab('man ').should == %w{4 5 6}
    end

    it "recompletes a method mission" do
      complete(:all_methods=>true)
      complete(:method=>'blah') { %w{1 2 3}}
      Bond.recomplete(:method=>'blah') { %w{4 5 6}}
      tab('blah ').should == %w{4 5 6}
    end

    it "recompletes an object mission" do
      complete(:object=>'String') { %w{1 2 3}}
      Bond.recomplete(:object=>'String') { %w{4 5 6}}
      tab('"blah".').should == %w{.4 .5 .6}
    end

    it "prints error if no existing mission" do
      complete(:object=>'String') { %w{1 2 3}}
      capture_stderr { Bond.recomplete(:object=>'Array') { %w{4 5 6}}}.should =~ /No existing mission/
      tab('[].').should == []
    end

    it "prints error if invalid condition given" do
      capture_stderr { Bond.recomplete}.should =~ /Invalid :action/
    end
  end

  describe "spy" do
    before_all {
      Bond.reset; complete(:on=>/end$/) { [] };
      complete(:all_methods=>true); complete(:method=>'the') { %w{spy who loved me} }
      complete(:object=>"Symbol")
    }

    it "detects basic mission" do
      capture_stdout { Bond.spy('the end')}.should =~ /end/
    end

    it "detects object mission" do
      capture_stdout { Bond.spy(':dude.i')}.should =~ /object.*Symbol.*dude\.id/m
    end

    it "detects method mission" do
      capture_stdout { Bond.spy('the ')}.should =~ /method.*the.*Kernel.*loved/m
    end

    it "detects no mission" do
      capture_stdout { Bond.spy('blah')}.should =~ /Doesn't match/
    end
  end
end