instance_meths = %w{instance_variable_get instance_variable_set remove_instance_variable instance_variable_defined?}
complete(:methods=>instance_meths, :class=>"Object#") {|e| e.object.instance_variables }
complete(:method=>"Object#instance_of?", :search=>:modules) { objects_of(Class) }
complete(:methods=>%w{is_a? kind_a? extend}, :class=>"Object#", :search=>:modules) { objects_of(Module) }
complete(:methods=>%w{Object#method Object#respond_to?}) {|e| e.object.methods }
complete(:method=>"Object#[]") {|e| e.object.keys rescue [] }
complete(:method=>"Object#send") {|e|
  if e.argument > 1
    if (meth = eval(e.arguments[0])) && meth.to_s != 'send' &&
      (action = MethodMission.find(e.object, meth.to_s))
      e.argument -= 1
      e.arguments.shift
      action[0].call(e)
    end
  else
    send_methods(e.object)
  end
}
def send_methods(obj)
  (obj.methods + obj.private_methods(false)).map {|e| e.to_s } - Mission::OPERATORS
end