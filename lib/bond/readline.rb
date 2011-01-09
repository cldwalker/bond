# This is the default readline plugin for Bond. A valid plugin must be an object
# that responds to methods setup and line_buffer as described below.
class Bond::Readline
  DefaultBreakCharacters = " \t\n\"\\'`><=;|&{("

  # Loads the readline-like library and sets the completion_proc to the given agent.
  def self.setup(agent)
    readline_setup

    # Reinforcing irb defaults
    Readline.completion_append_character = nil
    if Readline.respond_to?("basic_word_break_characters=")
      Readline.basic_word_break_characters = DefaultBreakCharacters
    end

    Readline.completion_proc = agent
  end

  def self.readline_setup
    require 'readline'
    load_extension unless Readline.respond_to?(:line_buffer)
    if (Readline::VERSION rescue nil).to_s[/editline/i]
      puts "Bond has detected EditLine and may not work with it." +
        " See the README's Limitations section."
    end
  end

  def self.load_extension
    require 'readline_line_buffer'
  rescue LoadError
    $stderr.puts "Bond Error: Failed to load readline_line_buffer. Ensure that it exists and was built correctly."
  end

  # Returns full line of what the user has typed.
  def self.line_buffer
    Readline.line_buffer
  end
end
