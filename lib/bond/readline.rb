module Bond
  # This is the default readline plugin for Bond. A valid plugin must be a module that defines methods setup
  # and line_buffer as described below.
  class Readline
    DefaultBreakCharacters = " \t\n\"\\'`><=;|&{("

    # Loads the readline-like library and sets the completion_proc to the given agent.
    def self.setup(agent)
      if RUBY_PLATFORM[/mswin|mingw|bccwin|wince/i]
        require 'rb-readline'
      else
        require 'readline'
        unless ::Readline.respond_to?(:line_buffer)
            RUBY_PLATFORM =~ /java/i ? load_jruby_extension : load_extension
        end
      end

      # Reinforcing irb defaults
      ::Readline.completion_append_character = nil
      if ::Readline.respond_to?("basic_word_break_characters=")
        ::Readline.basic_word_break_characters = DefaultBreakCharacters
      end

      ::Readline.completion_proc = agent
      if (::Readline::VERSION rescue nil).to_s[/editline/i]
        puts "Bond has detected EditLine and may not work with it. See the README's Limitations section."
      end
    end

    def self.load_jruby_extension
      require 'jruby'

      class << ::Readline
        ReadlineExt = org.jruby.ext.Readline
        def line_buffer
          ReadlineExt.s_get_line_buffer(JRuby.runtime.current_context, JRuby.reference(self))
        end
      end
    end

    def self.load_extension
      require 'readline_line_buffer'
    rescue LoadError
      $stderr.puts "Bond Error: Failed to load readline_line_buffer. Ensure that it exists and was built correctly."
    end

    # Returns full line of what the user has typed.
    def self.line_buffer
      ::Readline.line_buffer
    end
  end
end
