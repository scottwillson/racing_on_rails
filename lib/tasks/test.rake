require 'rake/testtask'

namespace :test do
  Rake::TestTask.new("ruby") do |t|
    t.test_files = FileList['test/ruby/**/*_test.rb'].shuffle
    t.verbose = true
  end
end
