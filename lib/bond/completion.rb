# any object's methods
complete :object=>"Object"
# method arguments
complete :all_methods=>true
complete :all_operator_methods=>true
# classes and constants
complete(:anywhere=>'(((::)?[A-Z][^:.\(]*)+)::?([^:.]*)', :action=>:constants)
# absolute constants
complete(:prefix=>'::', :anywhere=>'[A-Z][^:\.\(]*') {|e| Object.constants }
complete(:anywhere=>':[^:\s.]*') {|e|  Symbol.all_symbols.map {|f| ":#{f}" } rescue [] }
complete(:anywhere=>'\$[^\s.]*') {|e| global_variables }
complete(:on=>/[\s(]["']([^'"]*)$/, :search=>false, :action=>:quoted_files, :place=>:last)