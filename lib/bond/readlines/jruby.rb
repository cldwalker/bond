# Readline for Jruby
class Bond::Jruby < Bond::Readline
  def self.readline_setup
    require 'readline'
    require 'jruby'
    class << Readline
      ReadlineExt = org.jruby.ext.readline.Readline
      def line_buffer
        ReadlineExt.s_get_line_buffer(JRuby.runtime.current_context, JRuby.reference(self))
      end
    end
  end
end
