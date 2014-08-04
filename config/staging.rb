set :site_local_repository_branch, nil

role :app, "rocketsurgeryllc.com"
role :web, "rocketsurgeryllc.com"
role :db, "rocketsurgeryllc.com", primary: true

load "local/config/staging.rb" if File.exist?("local/config/staging.rb")

set :rails_env, "staging"
set :deploy_to, "/var/www/rails/#{application}"

load 'deploy/assets'
load "config/db"

require "capistrano-unicorn"
set :unicorn_rack_env, "staging"
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"

require "rvm/capistrano"
set :rvm_ruby_string, "ruby-2.1.2"
set :rvm_install_ruby_params, "--patch railsexpress"

set :scm, "git"
set :repository, "git://github.com/scottwillson/racing_on_rails.git"
set :site_local_repository, "git@github.com:scottwillson/#{application}-local.git"
set :deploy_via, :remote_cache
set :keep_releases, 5

set :bundle_without, [ :development, :test, :acceptance ]

set :user, "app"
set :use_sudo, false
set :scm_auth_cache, true

namespace :deploy do
  desc "Deploy association-specific customizations"
  task :local_code do
    if application != "racing_on_rails"
      if site_local_repository_branch
        run "git clone #{site_local_repository} -b #{site_local_repository_branch} #{release_path}/local"
      else
        run "git clone #{site_local_repository} #{release_path}/local"
      end
      run "chmod -R g+w #{release_path}/local"
      run "ln -s #{release_path}/local/public #{release_path}/public/local"

      run "if [ -e #{release_path}/local/config/unicorn/production.rb ]; then cp #{release_path}/local/config/unicorn/production.rb #{release_path}/config/unicorn/production.rb; fi"
    end
  end

  task :registration_engine do
    if application == "obra" || application == "nabra"
      run "if [ -e \"#{release_path}/lib/registration_engine\" ]; then rm -rf \"#{release_path}/lib/registration_engine\"; fi"
      run "if [ -L \"#{release_path}/lib/registration_engine\" ]; then rm -rf \"#{release_path}/lib/registration_engine\"; fi"
      run "git clone git@github.com:scottwillson/registration_engine.git #{release_path}/lib/registration_engine"
    end
  end

  task :symlinks do
    run <<-CMD
      mkdir #{latest_release}/tmp &&
      rm -rf #{latest_release}/tmp/pids &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
      rm -rf #{latest_release}/tmp/sockets &&
      ln -s #{shared_path}/sockets #{latest_release}/tmp/sockets &&
      rm -rf #{latest_release}/public/uploads &&
      ln -s #{shared_path}/uploads #{latest_release}/public/uploads
    CMD
  end

  namespace :web do
    desc "Present a maintenance page to visitors"
    task :disable, roles: :web, except: { no_release: true } do
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }
      run "if [ -f #{previous_release}/public/maintenance.html ]; then cp #{previous_release}/public/maintenance.html #{shared_path}/system/maintenance.html; fi"
      run "if [ -f #{previous_release}/local/public/maintenance.html ]; then cp #{previous_release}/local/public/maintenance.html #{shared_path}/system/maintenance.html; fi"
    end
  end
end

before "deploy:finalize_update", "deploy:symlinks", "deploy:local_code", "deploy:registration_engine"

after "deploy:restart", "unicorn:duplicate"

# Require last to ensure app callbacks are first
require 'bundler/capistrano'
