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

Rake::TestTask.new("test:acceptance") do |t|
  t.libs << "test"
  t.pattern = 'test/acceptance/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  namespace :acceptance do
    desc "Start Selenium RC server and run browser-based acceptance tests"
    task :browser => ["selenium:rc:start", "db:test:prepare", "test:server:start"] do
      begin
        Rake::Task["test:acceptance"].invoke
      ensure
        Rake::Task["selenium:rc:stop"].invoke rescue nil
        Rake::Task["test:server:stop"].invoke rescue nil
      end
    end
  end
  
  namespace :server do
    task :start do
      @pid = fork do
        # Since we can't use shell redirects without screwing 
        # up the pid, we'll reopen stdin and stdout instead
        # to get the same effect.
        [STDOUT,STDERR].each {|f| f.reopen '/dev/null', 'w' }
        exec "./script/server -e test"
      end
    end

    task :stop do
      %x{ kill #{@pid} }
    end
  end
end
