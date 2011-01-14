class Bond::Ffi < Bond::Readline
  def self.readline_setup
    require 'readline'
    require 'ffi'

    ::Readline.class_eval do
      extend FFI::Library
      ffi_lib '/usr/local/Cellar/readline/6.1/lib/libreadline.dylib'
      attach_variable :rl_line_buffer, :pointer

      def self.line_buffer
        Readline.rl_line_buffer.null? ? '' : rl_line_buffer.get_string(0)
      end
    end
  end
end
