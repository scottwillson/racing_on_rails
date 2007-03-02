# Do not use 'rake deploy: it's deprecated, and it will ignore your deploy.rb
# recipe in local/config. Use:
# cap -f local/config/deploy.rb -a deploy
require 'mongrel_cluster/recipes'

set :application, "racing_on_rails"
set :repository, "svn+ssh://butlerpress.com/var/repos/racing_on_rails/trunk"

# role :app, "my.server.com"
# role :db, 'my.server.com', :primary => true

set :deploy_to, "/var/www/rails/#{application}"

desc "Custom deployment"
task :deploy do
  transaction do
    update_code
    symlink
  
    # Pull in your local code
    run "svn co svn+ssh://my.svn_server.com/var/repos/local_application /var/www/rails/#{application}/current/local"

    migrate
    restart
  end
end

desc "Restart the web server"
task :restart, :roles => :app do
  restart_mongrel_cluster
end
