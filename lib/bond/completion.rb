# You shouldn't place Bond.complete statements before requiring this file
# unless you're also reproducing this Bond.debrief
Bond.debrief(:default_search=>:underscore) unless Bond.config[:default_search]
Bond.debrief(:default_mission=>:default) unless Bond.config[:default_mission]
# Must come before :symbols completion
Bond.complete(:all_methods=>true)

# irb/completion reproduced without the completion quirks
# Completes classes and constants
Bond.complete(:anywhere=>/((((::)?[A-Z][^:.\(]*)+)::?([^:.]*))$/, :action=>:constants, :search=>false)
# Completes absolute constants
Bond.complete(:anywhere=>/::([A-Z][^:\.\(]*)$/) {|e| Object.constants }
# Completes symbols
Bond.complete(:anywhere=>/(:[^:\s.]*)$/) {|e|
  Symbol.respond_to?(:all_symbols) ? Symbol.all_symbols.map {|f| ":#{f}" } : []
}
# Completes global variables
Bond.complete(:anywhere=>/(\$[^\s.]*)$/) {|e| global_variables }
# Completes files
Bond.complete(:on=>/[\s(]["']([^'"]*)$/, :search=>false, :action=>:quoted_files, :place=>:last)
# Completes any object's methods
Bond.complete(:object=>"Object", :place=>:last)
# Completes method completion anywhere in the line
Bond.complete(:on=>/([^.\s]+)\.([^.\s]*)$/, :object=>"Object", :place=>:last)