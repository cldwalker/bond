complete(:methods=>%w{Hash#delete Hash#fetch Hash#store}) {|e| e.object.keys }
complete(:method=>"Hash#index") {|e| e.object.values }