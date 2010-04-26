module Bond
  # Namespace in which completion files, ~/.bondrc and ~/.bond/completions/*.rb, are evaluated. Methods in this module,
  # Actions and Search can be used as top-level methods in completion files.
  module Rc
    extend self, Actions, Search

    # See Bond.complete
    def complete(*args, &block); Bond.complete(*args, &block); end
    # See Bond.recomplete
    def recomplete(*args, &block); Bond.recomplete(*args, &block); end
  end
end