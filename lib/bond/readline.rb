
module Bond
  module Readline
    Defaultbreakchars = " \t\n\"\\'`><=;|&{("

    def setup
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

      ::Readline.completion_append_character = nil
      if ::Readline.respond_to?("basic_word_break_characters=")
        ::Readline.basic_word_break_characters = Defaultbreakchars
      end
      ::Readline.completion_proc = self
    end

    def line_buffer
      ::Readline.line_buffer
    end
  end
end