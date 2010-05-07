complete(:methods=>%w{delete fetch store, [] has_key? key? include? member? values_at},
  :class=>"Hash#") {|e| e.object.keys }
complete(:methods=>%w{index value? has_value?}, :class=>"Hash#") {|e| e.object.values }