Rake::TestTask.new("test:acceptance") do |t|
  t.libs << "test"
  t.pattern = 'test/acceptance/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  desc "Start server and run browser-based acceptance tests"
  task acceptance: [ "db:test:prepare" ] do
    Rake::Task["test:acceptance"].invoke
  end
end
