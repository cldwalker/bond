complete(:methods=>%w{Kernel#raise Kernel#fail}) { objects_of(Class).select {|e| e < StandardError } }
complete(:methods=>%w{Kernel#system Kernel#exec}) {|e|
  ENV['PATH'].split(File::PATH_SEPARATOR).uniq.map {|e|
    File.directory?(e) ? Dir.entries(e) : []
  }.flatten.uniq - ['.', '..']
}
complete(:method=>"Kernel#require", :search=>:files) {
  paths = $:.map {|e| Dir["#{e}/**/*.{rb,bundle,dll,so}"].map {|f| f.sub(e+'/', '') } }.flatten
  if Object.const_defined?(:Gem)
    paths += Gem.path.map {|e| Dir["#{e}/gems/*/lib/*.{rb,bundle,dll,so}"].
      map {|f| f.sub(/^.*\//,'') } }.flatten
  end
  paths.uniq
}
complete(:methods=>%w{Kernel#trace_var Kernel#untrace_var}) { global_variables.map {|e| ":#{e}"} }