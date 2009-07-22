module Bond
  # Namespace for mission actions.
  module Actions
    ReservedWords = [
      "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined", "do", "else", "elsif", "end", "ensure",
      "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super",
      "then", "true", "undef", "unless", "until", "when", "while", "yield"
    ]

    # Helper function for evaluating strings in the current console binding.
    def current_eval(string)
      Missions::ObjectMission.current_eval(string)
    rescue Exception
      nil
    end

    # Completes backtick and Kernel#system with shell commands available in ENV['PATH']
    def shell_commands(input)
      ENV['PATH'].split(File::PATH_SEPARATOR).uniq.map {|e| Dir.entries(e) }.flatten.uniq - ['.', '..']
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
      receiver = input.matched[1]
      candidates = current_eval("#{receiver}.constants | #{receiver}.methods")
      candidates.grep(/^#{Regexp.escape(input.matched[4])}/).map {|e| receiver + "::" + e}
    end

    # Completes Kernel#require
    def method_require(input)
      fs = ::File::SEPARATOR
      extensions_regex = /((\.(so|dll|rb|bundle))|#{fs})$/i
      input =~ /^(\.{0,2}#{fs}|~)/ and return files(input).select {|f| f =~ extensions_regex or File.directory? f }
      dir_entries = proc {|dir| Dir.entries(dir).delete_if {|e| %w{. ..}.include?(e) }.map {|f|
         File.directory?(File.join(dir,f)) ? f+fs : f } }
      input_regex = /^#{Regexp.escape(input)}/

      $:.select {|e| File.directory?(e)}.inject([]) do |t,dir|
        if input[/.$/] == fs && File.directory?(File.join(dir,input))
          matches = dir_entries.call(File.join(dir,input)).select {|e| e =~ extensions_regex }.map {|e| input + e }
        else
          entries = input.include?(fs) && File.directory?(File.join(dir,File.dirname(input))) ?
           dir_entries.call(File.join(dir,File.dirname(input))).map {|e| File.join(File.dirname(input), e) } : dir_entries.call(dir)
          matches = entries.select {|e| e=~ extensions_regex && e =~ input_regex }
        end
        t += matches
      end
    end
  end
end