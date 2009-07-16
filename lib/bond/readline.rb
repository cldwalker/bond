
module Bond
  # This is the default readline plugin for Bond. A valid plugin must define methods setup() and line_buffer(). setup()
  # should load the readline-like library and set the completion_proc. line_buffer() should give access to the full line of what
  # the user has typed.
  module Readline
    DefaultBreakCharacters = " \t\n\"\\'`><=;|&{("

    def setup
      require 'readline'
      begin
        require 'readline_line_buffer'
      rescue LoadError
        $stderr.puts "Failed to load readline_line_buffer extension. Falling back on RubyInline extension."
        require 'inline'
        eval %[
          module ::Readline
            inline do |builder|
              %w(<errno.h> <stdio.h> <readline/readline.h>).each{|h| builder.include h }
              builder.c_raw_singleton <<-EOC
          static VALUE line_buffer(VALUE self)
          {
            rb_secure(4);
            if (rl_line_buffer == NULL)
          return Qnil;
            return rb_tainted_str_new2(rl_line_buffer);
          }
          EOC
            end
          end
        ]
      end

      # Reinforcing irb defaults
      ::Readline.completion_append_character = nil
      if ::Readline.respond_to?("basic_word_break_characters=")
        ::Readline.basic_word_break_characters = DefaultBreakCharacters
      end

      ::Readline.completion_proc = self
    end

    def line_buffer
      ::Readline.line_buffer
    end
  end
end