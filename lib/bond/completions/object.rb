complete(:method=>"Object#instance_variable_get") {|e| e.object.instance_variables }
complete(:method=>"Object#instance_variable_set") {|e| e.object.instance_variables }
complete(:method=>"Object#remove_instance_variable") {|e| e.object.instance_variables }
complete(:method=>"Object#instance_of?") { objects_of(Class) }
complete(:method=>"Object#is_a?") { objects_of(Module) }
complete(:method=>"Object#kind_a?") { objects_of(Module) }
complete(:method=>"Object#send") {|e| e.object.methods + e.object.private_methods - Kernel.methods }
complete(:method=>"Object#method") {|e|
  e.object.is_a?(Module) ? e.object.methods - e.object.class.methods : e.object.class.instance_methods(false)
}

def objects_of(klass)
  object = []
  ObjectSpace.each_object(klass) {|e| object.push(e) }
  object
end