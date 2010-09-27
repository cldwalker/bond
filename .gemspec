# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/bond/version"

Gem::Specification.new do |s|
  s.name        = "bond"
  s.version     = Bond::VERSION
  s.authors     = ["Gabriel Horner"]
  s.email       = "gabriel.horner@gmail.com"
  s.homepage    = "http://tagaholic.me/bond/"
  s.summary = "Mission: Easy custom autocompletion for arguments, methods and beyond. Accomplished for irb and any other readline-like console environments."
  s.description = "Bond is on a mission to improve irb's autocompletion. Aside from doing everything irb's can do and fixing its quirks, Bond can autocomplete argument(s) to methods, uniquely completing per module, per method and per argument. Bond brings irb's completion closer to bash/zsh as it provides a configuration system and a DSL for creating custom completions and completion rules. With this configuration system, users can customize their irb autocompletions and share it with others. Bond can also generate completions from yard documentation and load completions that ship with gems. Bond is able to offer more than irb's completion since it uses a Readline C extension to get the full line of input when completing as opposed to irb's last-word approach."
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = 'tagaholic'
  s.has_rdoc = 'yard'
  s.rdoc_options = ['--title', "Bond #{Bond::VERSION} Documentation"]
  s.add_development_dependency 'bacon', '>= 1.1.0'
  s.add_development_dependency 'mocha', '>= 0.9.8'
  s.add_development_dependency 'mocha-on-bacon'
  s.add_development_dependency 'bacon-bits'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.extensions = ["ext/readline_line_buffer/extconf.rb"]
  s.license = 'MIT'
end
