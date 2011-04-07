# placate rubygems when running `make install`
def dummy_makefile
  File.open(File.join(File.dirname(__FILE__), "Makefile"), "w") {|f|
    f.puts %[install:\n\techo "This is a dummy extension"]
  }
end

if RUBY_VERSION >= '1.9.2' || RUBY_PLATFORM[/java|mswin|mingw|bccwin|wince/i] ||
  ARGV.include?('--without-readline')
  dummy_makefile
else
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
end
