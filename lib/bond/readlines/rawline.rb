# A pure ruby readline which requires {rawline}[http://github.com/h3rald/rawline].
class Bond::Rawline < Bond::Readline
  def self.setup(agent)
    require 'rawline'
    Rawline.completion_append_character = nil
    Rawline.basic_word_break_characters= " \t\n\"\\'`><;|&{("
    Rawline.completion_proc = agent
  rescue LoadError
    abort "Bond Error: rawline gem is required for this readline plugin -> gem install rawline"
  end

  def self.line_buffer
    Rawline.editor.line.text
  end
end
