require 'mongrel_cluster/recipes'
load "config/db"
load "local/config/deploy.rb" if File.exists?("local/config/deploy.rb")

set :repository, 'http://butlerpress.com/var/repos/racing_on_rails/trunk'
set :local_repository, "http://butlerpress.com/var/repos/#{application}/trunk"

set :deploy_to, "/usr/local/www/rails/#{application}"

set :user, "app"
set :use_sudo, false
set :scm_auth_cache, true
set :mongrel_conf, "/usr/local/etc/mongrel_cluster/#{application}.yml"

desc "Show source control status of files on server, in case anyone has edited them directly"
task :edits do
  run "cd #{current_path}; svn stat"
  run "cd #{current_path}/local; svn stat"
end

desc "Commit modified files on server to source control, in case anyone has edited them directly"
task :commit_edits do
  # Can't commit from Rails root without side-stepping log symlink, so just do local for now
  run "cd #{current_path}/local; svn commit -m 'Manual updates'"
end

namespace :deploy do
  desc "Custom deployment"
  task :after_update do
    run "svn co #{local_repository} #{release_path}/local"
    run "chmod -R g+w #{release_path}/local"
  end
end
