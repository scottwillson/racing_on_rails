# Do not use 'rake deploy: it's deprecated, and it will ignore your deploy.rb
# recipe in local/config. Use:
# cap -f local/config/deploy.rb -a deploy
require 'mongrel_cluster/recipes'

set :application, 'racing_on_rails'
set :repository, 'http://butlerpress.com/var/repos/racing_on_rails/trunk'

set :deploy_to, "/var/www/rails/#{application}"

desc "Show source control status of files on server, in case anyone has edited them directly"
task :edits do
  run "cd #{current_path}; svn stat"
  run "cd #{current_path}/local; svn stat"
end

namespace :deploy do
  task :after_update do
    transaction do
      # Pull in your local code
      run "svn co svn+ssh://my.svn_server.com/var/repos/local_application /var/www/rails/#{application}/current/local"
      migrate
    end
  end

  task :restart, :roles => :app do
    restart_mongrel_cluster
  end
end
