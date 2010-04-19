complete(:method=>"Kernel#raise") { objects_of(Class).select {|e| e < StandardError } }
complete(:method=>"Kernel#fail") { objects_of(Class).select {|e| e < StandardError } }