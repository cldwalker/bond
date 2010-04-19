complete(:methods=>%w{Module#const_get Module#const_set Module#remove_const}) {|e| e.object.constants }
complete(:methods=>%{Module#class_variable_get Module#class_variable_set}) {|e| e.object.class_variables }
complete(:method=>"Module#instance_method") {|e| e.object.instance_methods(false) }