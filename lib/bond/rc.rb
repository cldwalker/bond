module Bond
  # Namespace in which ~/.bondrc is evaluated. Any methods in this class are valid top-level methods in ~/.bondrc.
  module Rc
    extend self

    # Loads file into Rc namespace
    def load(file)
      module_eval File.read(file)
    rescue Exception => e
      puts "Error: Plugin '#{file}' failed to load:", e.message
    end

    # See Bond.complete for usage
    def complete(*args, &block); Bond.complete(*args, &block); end
    # See Bond.recomplete for usage
    def recomplete(*args, &block); Bond.recomplete(*args, &block); end
    # See Bond.debrief for usage
    def debrief(*args, &block); Bond.debrief(*args, &block); end
    alias_method :set, :debrief

    # Evaluates methods in Actions to be used in completions
    def actions(&block)
      Actions.module_eval(&block)
    end
  end
end