require 'selenium/rake/tasks'

Selenium::Rake::RemoteControlStartTask.new do |rc|
  rc.port = 4444
  rc.timeout_in_seconds = 3 * 60
  rc.background = true
  rc.wait_until_up_and_running = true
  rc.jar_file = "/Users/sw/devel/racing_on_rails/vendor/plugins/webrat/vendor/selenium-server.jar"
  rc.additional_args << "-singleWindow"
end

Selenium::Rake::RemoteControlStopTask.new do |rc|
  rc.host = "localhost"
  rc.port = 4444
  rc.timeout_in_seconds = 3 * 60
end

Rake::TestTask.new(:acceptance => "db:test:prepare") do |t|
  t.libs << "test"
  t.pattern = 'test/acceptance/**/*_test.rb'
  t.verbose = true
end
Rake::Task['test:acceptance'].comment = "Run acceptance tests for web application"
