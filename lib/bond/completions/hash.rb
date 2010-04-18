complete(:method=>"Hash#delete") {|e| e.object.keys }
complete(:method=>"Hash#fetch") {|e| e.object.keys }
complete(:method=>"Hash#store") {|e| e.object.keys }
complete(:method=>"Hash#index") {|e| e.object.values }