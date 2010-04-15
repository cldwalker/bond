require File.join(File.dirname(__FILE__), 'test_helper')

context "Agent" do
  before_all { Bond.debrief(:readline_plugin=>valid_readline_plugin) }

  context "Agent" do
    before { Bond.agent.reset }

    test "chooses default mission if no missions match" do
      complete(:on=>/bling/) {|e| [] }
      Bond.agent.default_mission.expects(:execute)
      tabtab 'blah'
    end

    test "chooses default mission if internal processing fails" do
      complete(:on=>/bling/) {|e| [] }
      Bond.agent.expects(:find_mission).raises
      Bond.agent.default_mission.expects(:execute)
      tabtab('bling')
    end

    test "completes in middle of line" do
      complete(:object=>"Object")
      tabtab(':man.f blah', ':man.f').include?(':man.freeze').should == true
    end

    test "places missions last when declared last" do
      complete(:object=>"Symbol", :place=>:last)
      complete(:method=>"man", :place=>:last) { }
      complete(:on=>/man\s*(.*)/) {|e| [e.matched[1]] }
      Bond.agent.missions.map {|e| e.class}.should == [Bond::Mission, Bond::Missions::ObjectMission, Bond::Missions::MethodMission]
      tabtab('man ok').should == ['ok']
    end

    test "places mission correctly for a place number" do
      complete(:object=>"Symbol")
      complete(:method=>"man") {}
      complete(:on=>/man\s*(.*)/, :place=>1) {|e| [e.matched[1]] }
      tabtab('man ok')
      Bond.agent.missions.map {|e| e.class}.should == [Bond::Mission, Bond::Missions::ObjectMission, Bond::Missions::MethodMission]
      tabtab('man ok').should == ['ok']
    end
  end

  context "complete" do
    test "prints error if no action given" do
      capture_stderr { complete :on=>/blah/ }.should =~ /Invalid mission/
    end

    test "prints error if no condition given" do
      capture_stderr { complete {|e| []} }.should =~ /Invalid mission/
    end

    test "prints error if invalid condition given" do
      capture_stderr { complete(:on=>'blah') {|e| []} }.should =~ /Invalid mission/
    end

    test "prints error if invalid symbol action given" do
      capture_stderr { complete(:on=>/blah/, :action=>:bling) }.should =~ /Invalid mission action/
    end

    test "prints error if setting mission fails unpredictably" do
      Bond::Mission.expects(:create).raises(RuntimeError)
      capture_stderr { complete(:on=>/blah/) {|e| [] } }.should =~ /Mission setup failed/
    end
  end

  context "recomplete" do
    before {|e| Bond.agent.reset }

    test "recompletes a mission" do
      complete(:on=>/man/) { %w{1 2 3}}
      Bond.recomplete(:on=>/man/) { %w{4 5 6}}
      tabtab('man ').should == %w{4 5 6}
    end

    test "recompletes a method mission" do
      complete(:method=>'blah') { %w{1 2 3}}
      Bond.recomplete(:method=>'blah') { %w{4 5 6}}
      tabtab('blah ').should == %w{4 5 6}
    end

    test "recompletes an object mission" do
      complete(:object=>'String') { %w{1 2 3}}
      Bond.recomplete(:object=>'String') { %w{4 5 6}}
      tabtab('"blah".').should == %w{.4 .5 .6}
    end

    test "prints error if no existing mission" do
      complete(:object=>'String') { %w{1 2 3}}
      capture_stderr { Bond.recomplete(:object=>'Array') { %w{4 5 6}}}.should =~ /No existing mission/
      tabtab('[].').should == []
    end

    test "prints error if invalid condition given" do
      capture_stderr { Bond.recomplete}.should =~ /Invalid mission/
    end
  end

  context "spy" do
    before_all {
      Bond.reset; complete(:on=>/end$/) { [] }; complete(:method=>'the') { %w{spy who loved me} }
      complete(:object=>"Symbol")
    }

    test "detects basic mission" do
      capture_stdout { Bond.spy('the end')}.should =~ /end/
    end

    test "detects object mission" do
      capture_stdout { Bond.spy(':dude.i')}.should =~ /object.*Symbol.*dude\.id/m
    end

    test "detects method mission" do
      capture_stdout { Bond.spy('the ')}.should =~ /method.*the.*loved/m
    end

    test "detects no mission" do
      capture_stdout { Bond.spy('blah')}.should =~ /Doesn't match/
    end
  end
end