complete(:method=>"Kernel#raise") { objects_of(Class).select {|e| e < StandardError } }
complete(:method=>"Kernel#fail") { objects_of(Class).select {|e| e < StandardError } }
complete(:method=>"Kernel#system") {|e|
  ENV['PATH'].split(File::PATH_SEPARATOR).uniq.map {|e| Dir.entries(e) }.flatten.uniq - ['.', '..']
}
complete(:method=>"Kernel#require") {
  paths = $:.map {|e| Dir["#{e}/**/*.{rb,bundle,dll,so}"].map {|f| f.sub(e+'/', '') } }.flatten
  if Object.const_defined?(:Gem)
    paths += Gem.path.map {|e| Dir["#{e}/gems/*/lib/*.{rb,bundle,dll,so}"].
      map {|f| f.sub(/^.*\//,'') } }.flatten
  end
  paths.uniq
}