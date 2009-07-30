# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bond}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2009-07-30}
  s.description = %q{Bond is on a mission to make custom autocompletion easy in irb and other console/readline-like environments. Bond supports custom argument completion of methods, method completion of objects and anything else your wicked regex's can do. Bond comes armed with a Readline C extension to get the full line of input as opposed to irb's last-word based completion. Bond makes custom searching of possible completions easy which allows for nontraditional ways of autocompleting i.e. instant aliasing of multi worded methods.}
  s.email = %q{gabriel.horner@gmail.com}
  s.extensions = ["ext/readline_line_buffer/extconf.rb"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "CHANGELOG.rdoc",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "ext/readline_line_buffer/extconf.rb",
    "ext/readline_line_buffer/readline_line_buffer.c",
    "lib/bond.rb",
    "lib/bond/actions.rb",
    "lib/bond/agent.rb",
    "lib/bond/completion.rb",
    "lib/bond/mission.rb",
    "lib/bond/missions/default_mission.rb",
    "lib/bond/missions/method_mission.rb",
    "lib/bond/missions/object_mission.rb",
    "lib/bond/rawline.rb",
    "lib/bond/readline.rb",
    "lib/bond/search.rb",
    "test/agent_test.rb",
    "test/bond_test.rb",
    "test/completion_test.rb",
    "test/mission_test.rb",
    "test/object_mission_test.rb",
    "test/search_test.rb",
    "test/test_helper.rb"
  ]
  s.homepage = %q{http://tagaholic.me/bond/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{tagaholic}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Mission: Easy custom autocompletion for arguments, methods and beyond. Accomplished for irb and any other readline-like console environments.}
  s.test_files = [
    "test/agent_test.rb",
    "test/bond_test.rb",
    "test/completion_test.rb",
    "test/mission_test.rb",
    "test/object_mission_test.rb",
    "test/search_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
