require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/testtask'

module Tabular
  VERSION = "0.0.1"
end

desc "Run all tests"
task 'default' => ['test:units']

namespace 'test' do
  
  desc "Run unit tests"
  Rake::TestTask.new('units') do |t|
    t.test_files = FileList['test/**/*_test.rb']
    t.verbose = true
    t.warning = true
  end
end

desc 'Generate RDoc'
Rake::RDocTask.new('rdoc') do |task|
  task.main = 'README'
  task.title = "Tabular #{Tabular::VERSION}"
  task.rdoc_dir = 'doc'
end

def build_specification(version = Tabular::VERSION)
  Gem::Specification.new do |s|
    s.name        = "tabular"
    s.summary     = "Tabular data import and manipulation"
    s.version     = version
    s.platform    = Gem::Platform::RUBY
    s.author      = 'Scott Willson'
    s.description = <<-EOF
      Import CSV, tab-delimited, and Excel data. Read with common table interface.
    EOF
    s.email    = 'scott.willson@gmail.com'
    s.homepage = 'http://butlerpress.com'
    s.has_rdoc = true
    s.files    = FileList['{lib,test}/**/*.rb', '[A-Z]*'].to_a
  end
end

specification = build_specification

Rake::GemPackageTask.new(specification) do |package|
   package.need_zip = true
   package.need_tar = true
end

desc 'Generate updated gemspec with unique version, which will cause gem to be auto-built on github.'
task :update_gemspec do
  File.open('tabular.gemspec', 'w') do |output|
    output << build_specification(Tabular::VERSION + '.' + Time.now.strftime('%Y%m%d%H%M%S')).to_ruby
  end
end

desc "Do a full release."
task 'release' => ['default', 'generate_docs', 'publish_packages', 'publish_docs', 'update_gemspec'] do
  puts
  puts "*** Remember to commit newly generated gemspec after release ***"
  puts
end
