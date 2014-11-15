require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb'
begin
  Gem::Command.build_args = ARGV
  rescue NoMethodError
end

if RUBY_VERSION >= '1.9.2' || RUBY_PLATFORM[/java|mswin|mingw|bccwin|wince/i] || ARGV.include?('--without-readline')
  # create dummy rakefile to indicate success
  puts "create dummy RAKE file!!!"
  puts %Q[#{File.join(File.dirname(__FILE__), "Rakefile")}]
  File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w") do |io|
    io.write("task :default\n")
  end
else
  puts "create boring makefile"
  require "mkmf"
  dir_config("readline")
  have_library('readline')

  if !have_header('readline/readline.h')
    abort "\n** Bond Install Error: Unable to find readline.h. Please try again. **\n"+
    "To install with your readline: gem install bond -- --with-readline-dir=/path/to/readline\n"+
    "To install without readline: gem install bond -- --without-readline"
  else
    create_makefile 'readline_line_buffer'
  end
  File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w") do |io|
    io.puts <<RAKE
task :default do
  sh "make"
  sh "make install"
end
RAKE
  end
end
