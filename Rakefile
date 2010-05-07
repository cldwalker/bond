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
    s.description = "Bond is on a mission to improve irb’s autocompletion. Aside from doing everything irb’s can do and fixing its quirks, Bond can autocomplete argument(s) to methods, uniquely completing per module, per method and per argument. Bond brings irb’s completion closer to bash/zsh as it provides a configuration system and a DSL for creating custom completions and completion rules. With this configuration system, users can customize their irb autocompletions and share it with others. Bond is able to offer more than irb’s completion since it uses a Readline C extension to get the full line of input when completing as opposed to irb’s last-word approach."
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
