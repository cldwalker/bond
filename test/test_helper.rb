require 'bacon'
require 'bacon/bits'
require 'mocha-on-bacon'
require 'bond'
require 'rbconfig'

module TestHelpers
  extend self
  def mock_irb
    unless Object.const_defined?(:IRB)
      eval %[
        module ::IRB
          class<<self; attr_accessor :CurrentContext; end
          module InputCompletor; CompletionProc = lambda {|e| [] }; end
        end
      ]
      ::IRB.CurrentContext = stub(:workspace => stub(:binding => binding))
    end
  end

  def capture_stderr(&block)
    original_stderr = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = original_stderr
    end
    fake.string
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def tab(full_line, last_word=full_line)
    Bond.agent.weapon.stubs(:line_buffer).returns(full_line)
    Bond.agent.call(last_word)
  end

  def complete(*args, &block)
    Bond.complete(*args, &block)
  end

  def valid_readline
    Class.new { def self.setup(arg); end; def self.line_buffer; end }
  end

  def reset
    M.reset
    M.debrief :readline => TestHelpers.valid_readline
  end
end

class Bacon::Context
  include TestHelpers
end

# Default settings
Bond::M.debrief(:readline => TestHelpers.valid_readline, :debug => true)
include Bond
