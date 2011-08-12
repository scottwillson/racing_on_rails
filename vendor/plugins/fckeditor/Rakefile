require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'find'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the fckeditor plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the fckeditor plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Fckeditor'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# Globals
require File.expand_path(File.dirname(__FILE__) + "/lib/fckeditor_version")
PKG_NAME = 'fckeditor_plugin'
PKG_VERSION = FckeditorVersion.current

PKG_FILES = ['README', 'CHANGELOG', 'init.rb', 'install.rb']
PKG_DIRECTORIES = ['app/', 'lib/', 'public/', 'test/']
PKG_DIRECTORIES.each do |dir|
  Find.find(dir) do |f|
    if FileTest.directory?(f) and f =~ /\.svn/
      Find.prune
    else
      PKG_FILES << f
    end
  end
end
