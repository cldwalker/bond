# An enhanced irb/completion with some handy method completions

Bond.complete(:method=>/system|`/, :action=>:shell_commands)
Bond.complete(:method=>'require', :action=>:method_require, :search=>false)

# irb/completion mostly reproduced
Bond.complete(:object=>"Object", :search=>:underscore)
Bond.complete(:on=>/^(:[^:.]*)$/) {|e|
  Symbol.respond_to?(:all_symbols) ? Symbol.all_symbols.map {|f| ":#{f}" } : []
}
Bond.complete(:on=>/^(((::)?[A-Z][^:.\(]*)+)::?([^:.]*)$/, :action=>:constants, :search=>false)
Bond.complete(:on=>/^(\$[^.]*)$/, :search=>false) {|e|
  global_variables.grep(/^#{Regexp.quote(e.matched[1])}/)
}