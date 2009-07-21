# An enhanced irb/completion with some handy argument completions
Bond.debrief(:default_search=>:underscore) unless Bond.config[:default_search]
Bond.debrief(:default_mission=>:default) unless Bond.config[:default_mission]
Bond.complete(:method=>/system|`/, :action=>:shell_commands)
Bond.complete(:method=>'require', :action=>:method_require, :search=>false)

# irb/completion reproduced
Bond.complete(:on=>/(((::)?[A-Z][^:.\(]*)+)::?([^:.]*)$/, :action=>:constants, :search=>false)
Bond.complete(:on=>/::([A-Z][^:\.\(]*)$/, :search=>false) {|e|
  Object.constants.grep(/^#{Regexp.escape(e.matched[1])}/).collect{|f| "::" + f}
}
Bond.complete(:on=>/(:[^:\s.]*)$/) {|e|
  Symbol.respond_to?(:all_symbols) ? Symbol.all_symbols.map {|f| ":#{f}" } : []
}
Bond.complete(:on=>/(\$[^\s.]*)$/, :search=>false) {|e|
  global_variables.grep(/^#{Regexp.escape(e.matched[1])}/)
}
Bond.complete(:object=>"Object")
Bond.complete(:on=>/([^.\s]+)\.([^.\s]*)$/, :object=>"Object")