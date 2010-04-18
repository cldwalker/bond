complete(:method=>"Module#const_get") {|e| e.object.constants }
complete(:method=>"Module#const_set") {|e| e.object.constants }
complete(:method=>"Module#remove_const") {|e| e.object.constants }
complete(:method=>"Module#class_variable_get") {|e| e.object.class_variables }
complete(:method=>"Module#class_variable_set") {|e| e.object.class_variables }
complete(:method=>"Module#instance_method") {|e| e.object.instance_methods(false) }