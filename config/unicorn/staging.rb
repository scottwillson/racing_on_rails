rails_env = ENV['::Rails.env'] || 'staging'

worker_processes 1
preload_app true
timeout 180

user 'app', 'app'

app_path = File.expand_path(File.dirname(__FILE__) + "/../../../current")
working_directory app_path
listen "#{app_path}/tmp/sockets/unicorn.sock", :backlog => 64

stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

pid "#{app_path}/tmp/pids/unicorn.pid"

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
