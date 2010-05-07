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
  desc "Deploy association-specific customizations"
  task :local_code do
    if site_local_repository_branch
      run "git clone #{site_local_repository} -b #{site_local_repository_branch} #{release_path}/local"
    else
      run "git clone #{site_local_repository} #{release_path}/local"
    end
    run "chmod -R g+w #{release_path}/local"
    run "ln -s #{release_path}/local/public #{release_path}/public/local"
  end

  task :copy_cache do
    %w{ bar bar.html events people index.html results results.html teams teams.html }.each do |cached_path|
      run("cp -pr #{previous_release}/public/#{cached_path} #{release_path}/public/#{cached_path}") rescue nil
    end
  end
  
  task :wait_for_mongrels_to_stop do
    # Give Mongrels a chance to really stop
    sleep 10
    deploy.start
  end

  namespace :web do
    desc "Present a maintenance page to visitors"
    task :disable, :roles => :web, :except => { :no_release => true } do
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }
      run "if [ -f #{previous_release}/public/maintenance.html ]; then cp #{previous_release}/public/maintenance.html #{shared_path}/system/maintenance.html; fi"
      run "if [ -f #{previous_release}/local/public/maintenance.html ]; then cp #{release_path}/local/public/maintenance.html #{shared_path}/system/maintenance.html; fi"
    end
  end
end

after "deploy:update_code", "deploy:local_code", "deploy:copy_cache"
before "deploy:start", "deploy:wait_for_mongrels_to_stop"
