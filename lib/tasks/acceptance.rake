Rake::TestTask.new("test:acceptance") do |t|
  t.libs << "test"
  t.pattern = 'test/acceptance/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  namespace :acceptance do
    desc "Start server and run browser-based acceptance tests"
    task :browser => [ "db:test:prepare", "test:server:start" ] do
      begin
        Rake::Task["test:acceptance"].invoke
      ensure
        Rake::Task["test:server:stop"].invoke rescue nil
      end
    end
  end

  namespace :server do
    task :start do
      @pid = spawn("unicorn --env acceptance", [ STDOUT, STDERR ] => [ "log/unicorn.log", "w" ])
    end

    task :stop do
      %x{ kill #{@pid} }
    end
  end
end
