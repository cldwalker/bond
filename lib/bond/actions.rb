module Bond
  # Namespace for mission actions that can be shared and reused across completion definitions.
  module Actions
    ReservedWords = [
      "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined", "do", "else", "elsif", "end", "ensure",
      "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super",
      "then", "true", "undef", "unless", "until", "when", "while", "yield"
    ]

    # Helper function for evaluating strings in the current console binding.
    def current_eval(string)
      ObjectMission.current_eval(string)
    rescue Exception
      []
    end

    # Default completion for non-irb console and bond/completion
    def default(input)
      current_eval("methods | private_methods | local_variables | self.class.constants") | ReservedWords
    end

    # File completion
    def files(input)
      (::Readline::FILENAME_COMPLETION_PROC.call(input) || []).map {|f|
        f =~ /^~/ ?  File.expand_path(f) : f
      }
    end

    def quoted_files(input) #:nodoc:
      files(input.matched[1])
    end

    def constants(input) #:nodoc:
      receiver = input.matched[2]
      candidates = current_eval("#{receiver}.constants | #{receiver}.methods")
      candidates.grep(/^#{Regexp.escape(input.matched[5])}/).map {|e| receiver + "::" + e}
    end
  end
end