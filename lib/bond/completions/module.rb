complete(:methods=>%w{const_get const_set remove_const}, :class=>"Module#") {|e| e.object.constants }
complete(:methods=>%w{Module#class_variable_get Module#class_variable_set}) {|e| e.object.class_variables }
complete(:method=>"Module#instance_method") {|e| e.object.instance_methods(false) }
complete(:methods=>%w{< <= <=> > >=}, :class=>"Module#", :search=>:modules) { objects_of(Module) }