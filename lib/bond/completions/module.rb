complete(:methods=>%w{const_get const_set const_defined? remove_const}, :class=>"Module#") {|e| e.object.constants }
complete(:methods=>%w{class_variable_defined? class_variable_get class_variable_set remove_class_variable},
  :class=>"Module#") {|e| e.object.class_variables }
complete(:methods=>%w{instance_method method_defined? module_function remove_method undef_method},
  :class=>"Module#") {|e| e.object.instance_methods }
complete(:method=>"Module#public") {|e| e.object.private_instance_methods + e.object.protected_instance_methods }
complete(:method=>"Module#private") {|e| e.object.instance_methods + e.object.protected_instance_methods }
complete(:method=>"Module#protected") {|e| e.object.instance_methods + e.object.private_instance_methods }
complete(:methods=>%w{< <= <=> > >= include? include}, :class=>"Module#", :search=>:modules) { objects_of(Module) }
complete(:method=>'Module#alias_method') {|e| e.argument > 1 ? e.object.instance_methods : [] }