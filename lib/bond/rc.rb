module Bond
  # Namespace in which completion files, ~/.bondrc and ~/.bond/completions/*.rb, are evaluated. Methods in this module
  # and Search are the DSL in completion files and can be used within completion actions.
  #
  # === Example ~/.bondrc
  #   # complete arguments for any object's :respond_to?
  #   complete(:method => "Object#respond_to?") {|e| e.object.methods }
  #   # complete arguments for any module's :public
  #   complete(:method => "Module#public") {|e| e.object.instance_methods }
  #
  #   # Share generate_tags action across completions
  #   complete(:method => "edit_tags", :action => :generate_tags)
  #   complete(:method => "delete_tags", :search => false) {|e| generate_tags(e).grep(/#{e}/i) }
  #
  #   def generate_tags(input)
  #    ...
  #   end
  module Rc
    extend self, Search

    # See {Bond#complete}
    def complete(*args, &block); M.complete(*args, &block); end
    # See {Bond#recomplete}
    def recomplete(*args, &block); M.recomplete(*args, &block); end

    # Action method with search which returns array of files that match current input.
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

    # Calls eval with Mission.current_eval, rescuing any exceptions to return nil.
    # If Bond.config[:debug] is true, exceptions are raised again.
    def eval(str)
      Mission.current_eval(str)
    rescue Exception
      raise if Bond.config[:debug]
    end
  end
end
