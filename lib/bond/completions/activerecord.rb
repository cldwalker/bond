attribute_imethods = (%w{attribute_for_inspect column_for_attribute decrement} +
  %w{increment update_attribute toggle update_attributes}).map {|e| "ActiveRecord::Base##{e}"}
complete(:methods=>attribute_imethods) {|e| e.object.attribute_names }

attribute_cmethods = (%w{attr_accessible attr_protected attr_readonly create create! decrement_counter} +
  %w{destroy_all exists? increment_counter new serialize update update_all update_counters where}).map {|e| "ActiveRecord::Base.#{e}"}
complete(:methods=>attribute_cmethods) {|e| e.object.column_names }

complete(:method=>"ActiveRecord::Base.establish_connection") { %w{adapter host username password database} }
complete(:methods=>%w{ActiveRecord::Base.find ActiveRecord::Base.all ActiveRecord::Base.first ActiveRecord::Base.last}) {
  %w{conditions order group having limit offset joins include select from readonly lock}
}
