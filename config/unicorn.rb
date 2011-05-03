# unicorn_rails -c /usr/local/etc/unicorn/wsba.rb -E production -D

rails_env = ENV['::Rails.env'] || 'production'

worker_processes 2
timeout 90

rails_root = File.expand_path(File.dirname(__FILE__) + "/../")
working_directory rails_root
listen "#{rails_root}/tmp/sockets/unicorn.sock", :backlog => 64
stderr_path "#{rails_root}/log/unicorn.stderr.log"
stdout_path "#{rails_root}/log/unicorn.stdout.log"
