instance_meths = %w{instance_variable_get instance_variable_set remove_instance_variable}
complete(:methods=>instance_meths, :class=>"Object#") {|e| e.object.instance_variables }
complete(:method=>"Object#instance_of?") { objects_of(Class) }
complete(:methods=>%w{Object#is_a? Object#kind_a?}) { objects_of(Module) }
complete(:method=>"Object#method") {|e|
  e.object.is_a?(Module) ? e.object.methods - e.object.class.methods : e.object.class.instance_methods(false)
}
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