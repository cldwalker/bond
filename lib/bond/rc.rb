module Bond
  # Namespace in which completion files, ~/.bondrc and ~/.bond/completions/*.rb, are evaluated. Methods in this module
  # and Search can be used as top-level methods in completion files and in completion actions.
  module Rc
    extend self, Search

    # See Bond.complete
    def complete(*args, &block); Bond.complete(*args, &block); end
    # See Bond.recomplete
    def recomplete(*args, &block); Bond.recomplete(*args, &block); end

    # Action method which returns array of files that match current input.
    def files(input)
      (::Readline::FILENAME_COMPLETION_PROC.call(input) || []).map {|f|
        f =~ /^~/ ?  File.expand_path(f) : f
      }
    end

    # Helper method which returns objects of a given class.
    def objects_of(klass)
      object = []
      ObjectSpace.each_object(klass) {|e| object.push(e) }
      object
    end
  end
end