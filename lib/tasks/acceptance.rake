Rake::TestTask.new("test:acceptance") do |t|
  t.libs << "test"
  t.pattern = 'test/acceptance/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  namespace :acceptance do
    desc "Start server and run browser-based acceptance tests"
    task :browser => ["db:test:prepare", "test:server:start"] do
      begin
        Rake::Task["test:acceptance"].invoke
      ensure
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
        exec "./script/server -e acceptance"
      end
    end

    task :stop do
      %x{ kill #{@pid} }
    end
  end
end
