require 'rake'
require 'fileutils'

def gemspec
  @gemspec ||= eval(File.read('.gemspec'), binding, '.gemspec')
end

def gem_file
  "#{gemspec.name}-#{gemspec.version}#{ENV['GEM_PLATFORM'] == 'java' ? '-java' : ''}.gem"
end

desc "Build the gem"
task :gem=>:gemspec do
  sh "gem build .gemspec"
  FileUtils.mkdir_p 'pkg'
  FileUtils.mv gem_file, 'pkg'
end

desc "Build gems for the default and java platforms"
task :all_gems => :gem do
  ENV['GEM_PLATFORM'] = 'java'
  @gemspec = nil
  Rake::Task["gem"].reenable
  Rake::Task["gem"].invoke
end

desc "Install the gem locally"
task :install => :gem do
  sh %{gem install pkg/#{gem_file}}
end

desc "Generate the gemspec"
task :generate do
  puts gemspec.to_ruby
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

desc 'Run tests'
task :test do |t|
  sh 'bacon -q -Ilib -I. test/*_test.rb'
end

task :default => :test
