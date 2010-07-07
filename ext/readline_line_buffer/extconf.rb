require "mkmf"
dir_config("readline")
dir_config 'readline_line_buffer'
unless have_header('readline/readline.h')
  STDERR.puts "-" * 80
  STDERR.puts "Error! Cannot find readline/readline.h"
  STDERR.puts "If you have it installed in a non-standard directory, try installing the gem via `gem install bond -- --with-readline-dir=/path/to/readline`"
  STDERR.puts "-" * 80
  exit 1
end
create_makefile 'readline_line_buffer'
