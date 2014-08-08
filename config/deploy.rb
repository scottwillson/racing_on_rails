lock "3.2.1"

set :linked_dirs, %w{bin log public/system public/uploads tmp/pids tmp/cache tmp/sockets vendor/bundle }
set :linked_files, %w{config/database.yml config/newrelic.yml config/secrets.yml}

set :bundle_jobs, 4

set :puma_threads, [ 8, 32 ]

set :site_local_repository_branch, "deployment"

load "local/config/deploy.rb" if File.exist?("local/config/deploy.rb")

set :deploy_to, "/var/www/rails/#{application}"

set :rvm_ruby_string, "ruby-2.1.2"
set :rvm_install_ruby_params, "--patch railsexpress"

set :repository, "git://github.com/scottwillson/racing_on_rails.git"
set :branch, "deployment"
set :site_local_repository, "git@github.com:scottwillson/#{application}-local.git"

set :user, "app"

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
      run "git clone git@github.com:scottwillson/registration_engine.git -b deployment #{release_path}/lib/registration_engine"
    end
  end
end

before "deploy:finalize_update", "deploy:symlinks", "deploy:copy_cache", "deploy:registration_engine"
