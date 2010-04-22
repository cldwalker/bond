# Completes any object's methods
complete :object=>"Object"
# Completes method arguments
complete :all_methods=>true
complete :all_operator_methods=>true

# irb/completion reproduced without the completion quirks
# Completes classes and constants
complete(:anywhere=>'(((::)?[A-Z][^:.\(]*)+)::?([^:.]*)', :action=>:constants)
# Completes absolute constants
complete(:prefix=>'::', :anywhere=>'[A-Z][^:\.\(]*') {|e| Object.constants }
# Completes symbols
complete(:anywhere=>':[^:\s.]*') {|e|
  Symbol.respond_to?(:all_symbols) ? Symbol.all_symbols.map {|f| ":#{f}" } : []
}
# Completes global variables
complete(:anywhere=>'\$[^\s.]*') {|e| global_variables }
# Completes files
complete(:on=>/[\s(]["']([^'"]*)$/, :search=>false, :action=>:quoted_files, :place=>:last)