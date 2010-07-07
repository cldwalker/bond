require "mkmf"

if RUBY_VERSION < '1.9.2'
  dir_config("readline")
  unless have_header('readline/readline.h')
    $stderr.puts "-" * 80
    $stderr.puts "Error! Cannot find readline/readline.h."
    $stderr.puts "Readline was probably installed in a non-standard directory.",
      "Try `gem install bond -- --with-readline-dir=/path/to/readline`."
    $stderr.puts "-" * 80
    exit 1
  end
  create_makefile 'readline_line_buffer'
else
  # Create dummy Makefile to placate rubygems when running `make install`.
  File.open(File.join(File.dirname(__FILE__), "Makefile"), "w") {|f|
    f.puts %[install:\n\techo "This is a dummy extension"]
  }
end
