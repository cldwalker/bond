require 'rake'
begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.rcov_opts = ["-T -x '/Library/Ruby/*'"]
    t.verbose = true
  end
rescue LoadError
end

begin
  require 'jeweler'
  require File.dirname(__FILE__) + "/lib/bond/version"

  Jeweler::Tasks.new do |s|
    s.name = "bond"
    s.version = Bond::VERSION
    s.summary = "Mission: Easy custom autocompletion for arguments, methods and beyond. Accomplished for irb and any other readline-like console environments."
    s.description = "Bond is on a mission to make custom autocompletion easy in irb and other console/readline-like environments. Bond supports custom argument completion of methods, method completion of objects and anything else your wicked regex's can do. Bond comes armed with a Readline C extension to get the full line of input as opposed to irb's last-word based completion. Bond makes custom searching of possible completions easy which allows for nontraditional ways of autocompleting i.e. instant aliasing of multi worded methods."
    s.email = "gabriel.horner@gmail.com"
    s.homepage = "http://tagaholic.me/bond/"
    s.authors = ["Gabriel Horner"]
    s.rubyforge_project = 'tagaholic'
    s.has_rdoc = true
    s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
    s.extensions = ["ext/readline_line_buffer/extconf.rb"]
    s.files = FileList["CHANGELOG.rdoc", "Rakefile", "README.rdoc", "LICENSE.txt", "{bin,lib,test,ext}/**/*"]
  end

rescue LoadError
end

task :default => :test

desc 'Run specs with unit test style output'
task :test do |t|
  sh 'bacon -q -Ilib test/*_test.rb'
end
