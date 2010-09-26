# any object's methods
complete :object=>"Object"
# method arguments
complete :all_methods=>true
complete :all_operator_methods=>true
# classes and constants
complete(:name=>:constants, :anywhere=>'([A-Z][^. \(]*)::([^: .]*)') {|e|
  receiver = e.matched[2]
  candidates = eval("#{receiver}.constants | #{receiver}.methods") || []
  normal_search(e.matched[3], candidates).map {|e| "#{receiver}::#{e}" }
}
# absolute constants
complete(:prefix=>'::', :anywhere=>'[A-Z][^:\.\(]*') {|e| Object.constants }
complete(:anywhere=>':[^:\s.]*') {|e|  Symbol.all_symbols.map {|f| ":#{f}" } rescue [] }
complete(:anywhere=>'\$[^\s.]*') {|e| global_variables }
complete(:name=>:quoted_files, :on=>/[\s(]["']([^'"]*)$/, :search=>false, :place=>:last) {|e| files(e.matched[1]) }
