module Bond
  module Rc
    extend self
    def complete(*args, &block); Bond.complete(*args, &block); end
    def recomplete(*args, &block); Bond.recomplete(*args, &block); end
    def debrief(*args, &block); Bond.debrief(*args, &block); end
    alias_method :set, :debrief
    
    def actions(&block)
      Actions.module_eval(&block)
    end
  end
end