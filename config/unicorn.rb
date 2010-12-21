# unicorn_rails -c /usr/local/etc/unicorn/wsba.rb -E production -D

rails_env = ENV['RAILS_ENV'] || 'production'

worker_processes 2
preload_app true
timeout 90

rails_root = File.expand_path(File.dirname(__FILE__) + "/../")
listen "#{rails_root}/tmp/sockets/unicorn.sock", :backlog => 64
stderr_path "#{rails_root}/log/unicorn.stderr.log"
stdout_path "#{rails_root}/log/unicorn.stdout.log"

# Using this method we get 0 downtime deploys.
before_fork do |server, worker|
  old_pid = RAILS_ROOT + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection

  # per-process listener ports for debugging/admin:
  worker.user('app', 'rails') if Process.euid == 0
end
