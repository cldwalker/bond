require "mkmf"
have_header 'readline/readline.h'
dir_config 'readline_line_buffer'
create_makefile 'readline_line_buffer'
