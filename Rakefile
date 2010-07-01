# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require 'hydra'
  require 'hydra/tasks'

  Hydra::TestTask.new('hydra') do |t|
    t.add_files 'test/unit/**/*_test.rb'
    t.add_files 'test/functional/**/*_test.rb'
    t.add_files 'test/integration/**/*_test.rb'
  end
rescue
  # Don't worry about Hydra
end
