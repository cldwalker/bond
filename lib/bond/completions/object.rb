instance_meths = %w{Object#instance_variable_get Object#instance_variable_set Object#remove_instance_variable}
complete(:methods=>instance_meths) {|e| e.object.instance_variables }
complete(:method=>"Object#instance_of?") { objects_of(Class) }
complete(:methods=>%w{Object#is_a? Object#kind_a?}) { objects_of(Module) }
complete(:method=>"Object#send") {|e| e.object.methods + e.object.private_methods - Kernel.methods }
complete(:method=>"Object#method") {|e|
  e.object.is_a?(Module) ? e.object.methods - e.object.class.methods : e.object.class.instance_methods(false)
}