# unicorn_rails -c /usr/local/etc/unicorn/wsba.rb -E production -D

rails_env = ENV['::Rails.env'] || 'production'

worker_processes 2
preload_app true
timeout 90

# Using this method we get 0 downtime deploys.
before_fork do |server, worker|
  old_pid = ::Rails.root.to_s + '/tmp/pids/unicorn.pid.oldbin'
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

  # per-process listener ports for debugging/admin:
  addr = "127.0.0.1:#{9035 + worker.nr}"
  server.listen(addr, :tries => -1, :delay => 5, :backlog => 128)
  worker.user('app', 'rail') if Process.euid == 0
end
