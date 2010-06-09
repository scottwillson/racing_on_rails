require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "tabular"
    gemspec.summary = "Read, write, and manipulate CSV, tab-delimited and Excel data"
    gemspec.description = "Tabular is a Ruby library for reading, writing, and manipulating CSV, tab-delimited and Excel data."
    gemspec.email = "scott.willson@gmail.cpm"
    gemspec.homepage = "http://github.com/scottwillson/tabular"
    gemspec.authors = ["Scott Willson"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tabular #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
