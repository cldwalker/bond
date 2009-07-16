require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.rcov_opts = ["-T -x '/Library/Ruby/*'"]
    t.verbose = true
  end
rescue LoadError
  puts "Rcov not available. Install it for rcov-related tasks with: sudo gem install rcov"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "bond"
    s.summary = "Mission: Easy custom autocompletion for arguments, methods and beyond. Accomplished for irb and any other readline-like console environments."
    s.description = "Bond is on a mission to make custom autocompletion easy in irb and other console/readline-like environments. Bond supports custom argument completion of methods, method completion of objects and anything else your wicked regex's can do. Bond comes armed with a Readline C extension to get the full line of input as opposed to irb's last-word based completion. Bond makes custom searching of possible completions easy which allows for nontraditional ways of autocompleting i.e. instant aliasing of multi worded methods."
    s.email = "gabriel.horner@gmail.com"
    s.homepage = "http://tagaholic.me/bond/"
    s.authors = ["Gabriel Horner"]
    s.has_rdoc = true
    s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
    s.extensions = ["ext/readline_line_buffer/extconf.rb"]
    s.files = FileList["CHANGELOG.rdoc", "Rakefile", "README.rdoc", "VERSION.yml", "LICENSE.txt", "{bin,lib,test,ext}/**/*"]
  end

rescue LoadError
  puts "Jeweler not available. Install it for jeweler-related tasks with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'test'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# I assume contributors can edit the gemspec for most attributes except for file-related ones.
# For those attributes you can use the gemspec_update task. I prefer not to give you the gem-creator-specific rake
# tasks I use to generate gemspecs to give you the choice of generating gemspecs however you'd like.
# More about this here: http://tagaholic.me/2009/04/08/building-dry-gems-with-thor-and-jeweler.html .
desc "Update gemspec from existing one by regenerating path globs specified in *.gemspec.yml or defaults to liberal path globs."
task :gemspec_update  do
  if (gemspec_file = Dir['*.gemspec'][0])
    original_gemspec = eval(File.read(gemspec_file))
    if File.exists?("#{gemspec_file}.yml")
      require 'yaml'
      YAML::load_file("#{gemspec_file}.yml").each do |attribute, globs|
        original_gemspec.send("#{attribute}=", FileList[globs])
      end
    else
      # liberal defaults
      original_gemspec.files = FileList["**/*"]
      test_directories = original_gemspec.test_files.grep(/\//).map {|e| e[/^[^\/]+/]}.compact.uniq
      original_gemspec.test_files = FileList["{#{test_directories.join(',')}}/**/*"] unless test_directories.empty?
    end
    File.open(gemspec_file, 'w') {|f| f.write(original_gemspec.to_ruby) }
    puts "Updated gemspec."
  else
    puts "No existing gemspec file found."
  end
end

task :default => :test
