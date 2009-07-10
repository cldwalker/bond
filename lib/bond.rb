current_dir = File.dirname(__FILE__)
$:.unshift(current_dir) unless $:.include?(current_dir) || $:.include?(File.expand_path(current_dir))
require 'bond/readline'

class Bond
  attr_reader :handlers
  Defaultbreakchars = " \t\n\"\\'`><=;|&{("

  def initialize(options={})
    @handlers = {}
    Readline.completion_append_character = nil
    if Readline.respond_to?("basic_word_break_characters=")
      Readline.basic_word_break_characters = Defaultbreakchars
    end
    Readline.completion_proc = self
  end

  def complete(pattern, options={}, &block) 
    @handlers[pattern] = options.merge :block=>block
  end

  def call(input)
    handler, new_input = find_handler(input)
    handler.call(new_input)
  rescue
    p $!
    p $!.backtrace.slice(0,5)
    default_handler.call(input)
  end

  def find_handler(input)
    if @handlers.values.any? {|e| e.has_key?(:command) }
      all_input = Readline.line_buffer
      match = all_input.match /^\s*(\S+)\s*(.*)$/
      if (command = match[1])
        @handlers.values.each do |handler|
          return [handler[:block], match[2]] if handler[:command] == command
        end
      end
    end
    @handlers.each do |pattern,handler| 
      if match = input.match(pattern)
        return [handler[:block], input]
      end
    end
    [default_handler, input]
  end

  def default_handler
    IRB::InputCompletor::CompletionProc
  end
end
