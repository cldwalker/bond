complete(:method=>"Kernel#raise") { objects_of(Class).select {|e| e < StandardError } }
complete(:method=>"Kernel#fail") { objects_of(Class).select {|e| e < StandardError } }
complete(:method=>"Kernel#system") {|e|
  ENV['PATH'].split(File::PATH_SEPARATOR).uniq.map {|e| Dir.entries(e) }.flatten.uniq - ['.', '..']
}