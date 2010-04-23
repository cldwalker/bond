module Bond
  # Namespace for mission actions that can be shared and reused across completion definitions.
  module Actions
    ReservedWords = [
      "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined", "do", "else", "elsif", "end", "ensure",
      "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super",
      "then", "true", "undef", "unless", "until", "when", "while", "yield"
    ]

    # Default completion for non-irb console and bond/completion
    def default(input)
      Mission.current_eval("methods | private_methods | local_variables | self.class.constants") | ReservedWords
    end

    # File completion
    def files(input)
      (::Readline::FILENAME_COMPLETION_PROC.call(input) || []).map {|f|
        f =~ /^~/ ?  File.expand_path(f) : f
      }
    end

    # Returns objects of a given class
    def objects_of(klass)
      object = []
      ObjectSpace.each_object(klass) {|e| object.push(e) }
      object
    end
  end
end