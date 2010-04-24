module Bond
  # Namespace in which ~/.bondrc is evaluated. Any methods in this class are valid top-level methods in ~/.bondrc.
  module Rc
    extend self, Actions, Search

    # See Bond.complete for usage
    def complete(*args, &block); Bond.complete(*args, &block); end
    # See Bond.recomplete for usage
    def recomplete(*args, &block); Bond.recomplete(*args, &block); end
  end
end