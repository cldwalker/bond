attribute_imethods = %w{attribute_for_inspect column_for_attribute decrement} +
  %w{increment update_attribute toggle update_attributes []}
complete(:methods=>attribute_imethods, :class=>"ActiveRecord::Base#") {|e| e.object.attribute_names }

attribute_cmethods = %w{attr_accessible attr_protected attr_readonly create create! decrement_counter} +
  %w{destroy_all exists? increment_counter new serialize update update_all update_counters where}
complete(:methods=>attribute_cmethods, :class=>'ActiveRecord::Base.') {|e| e.object.column_names }

complete(:method=>"ActiveRecord::Base.establish_connection") { %w{adapter host username password database} }
complete(:methods=>%w{find all first last}, :class=>'ActiveRecord::Base.') {
  %w{conditions order group having limit offset joins include select from readonly lock}
}