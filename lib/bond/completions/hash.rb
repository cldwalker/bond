complete(:methods=>%w{delete fetch store}, :class=>"Hash#") {|e| e.object.keys }
complete(:method=>"Hash#index") {|e| e.object.values }