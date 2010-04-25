require File.join(File.dirname(__FILE__), 'test_helper')

describe "Agent" do
  describe "#call" do
    before { Bond.agent.reset }

    it "chooses default mission if no missions match" do
      complete(:on=>/bling/) {|e| [] }
      Bond.agent.default_mission.expects(:execute)
      tab 'blah'
    end

    it "chooses default mission if internal processing fails" do
      capture_stdout {
        complete(:on=>/bling/) {|e| [] }
        Bond.agent.expects(:find_mission).raises
        Bond.agent.default_mission.expects(:execute)
        tab('bling')
      }.should.not.be.empty
    end

    it "prints error and stacktrace if completion action raises error and debug" do
      complete(:on=>/blah/) { raise 'blah' }
      errors = tab('blah')
      errors.size.should == 3
      errors[0].should =~ /Bond Error:.*action.*'blah'/
      errors[2].should =~ /Debug Info/
    end

    it "prints error if completion action raises error" do
      Bond.config[:debug] = false
      complete(:on=>/blah/) { raise 'blah' }
      errors = tab('blah')
      errors.size.should == 2
      Bond.config[:debug] = true
    end

    it "prints error if completion search raises error" do
      Rc.module_eval "def blah_search(*args); raise 'blah'; end"
      complete(:on=>/blah/, :search=>:blah) { [1] }
      errors = tab('blah')
      errors.size.should == 3
      errors[0].should =~ /Bond Error:.*search.*'blah'/
    end
  end

  describe "complete" do
    before {|e| Bond.agent.reset }
    it "prints error if no action given" do
      capture_stderr { complete :on=>/blah/ }.should =~ /Invalid mission/
    end

    it "prints error if no condition given" do
      capture_stderr { complete {|e| []} }.should =~ /Invalid mission/
    end

    it "prints error if invalid condition given" do
      capture_stderr { complete(:on=>'blah') {|e| []} }.should =~ /Invalid mission/
    end

    it "prints error if setting mission fails unpredictably" do
      Mission.expects(:create).raises(RuntimeError)
      capture_stderr { complete(:on=>/blah/) {|e| [] } }.should =~ /Mission setup failed/
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
      capture_stderr { Bond.recomplete}.should =~ /Invalid mission/
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