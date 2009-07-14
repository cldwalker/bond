module Bond
  module Rawline
    def setup
      require 'rawline'
      ::Rawline.completion_append_character = nil
      ::Rawline.basic_word_break_characters= " \t\n\"\\'`><;|&{(" 
      ::Rawline.completion_proc = self
    end

    def line_buffer
      ::Rawline.editor.line.text
    end
  end
end