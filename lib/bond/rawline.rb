module Bond
  # A readline plugin for use with {Rawline}[http://github.com/h3rald/rawline]. This plugin
  # should be used in conjunction with {a Rawline shell}[http://www.h3rald.com/articles/real-world-rawline-usage].
  class Rawline
    def self.setup(agent)
      require 'rawline'
      ::Rawline.completion_append_character = nil
      ::Rawline.basic_word_break_characters= " \t\n\"\\'`><;|&{(" 
      ::Rawline.completion_proc = agent
    end

    def self.line_buffer
      ::Rawline.editor.line.text
    end
  end
end
