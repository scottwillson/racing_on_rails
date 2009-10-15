require 'mongrel_cluster/recipes'
load "config/db"
load "local/config/deploy.rb" if File.exists?("local/config/deploy.rb")

set :scm, "git"
set :repository, "git://github.com/scottwillson/racing_on_rails.git"
set :site_local_repository, "git@butlerpress.com:#{application}.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :deploy_to, "/usr/local/www/rails/#{application}"

set :user, "app"
set :use_sudo, false
set :scm_auth_cache, true
set :mongrel_conf, "/usr/local/etc/mongrel_cluster/#{application}.yml"

namespace :deploy do
  desc "Custom deployment"
  task :after_update_code do
    run "git clone #{site_local_repository} #{release_path}/local"
    run "chmod -R g+w #{release_path}/local"
  end
end
