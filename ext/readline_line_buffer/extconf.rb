require "mkmf"

# placate rubygems when running `make install`
def dummy_makefile
  File.open(File.join(File.dirname(__FILE__), "Makefile"), "w") {|f|
    f.puts %[install:\n\techo "This is a dummy extension"]
  }
end

if RUBY_VERSION < '1.9.2' && !defined?(JRUBY_VERSION)
  dir_config("readline")
  have_library('readline')
  if !have_header('readline/readline.h')
    puts "Bond was built without readline. To use it with readline: gem install bond" +
      " -- --with-readline-dir=/path/to/readline"
    dummy_makefile
  else
    create_makefile 'readline_line_buffer'
  end
else
  dummy_makefile
end
