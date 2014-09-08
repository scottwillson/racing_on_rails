lock "3.2.1"

set :linked_dirs, %w{log public/assets public/system public/uploads tmp/pids tmp/cache tmp/sockets vendor/bundle }
set :linked_files, %w{config/database.yml config/newrelic.yml config/secrets.yml}

set :bundle_jobs, 4
set :bundle_without, %w{development test acceptance}.join(' ')

set :puma_preload_app, false
set :puma_threads, [ 8, 32 ]
set :puma_workers, 1

load "local/config/deploy.rb" if File.exist?("local/config/deploy.rb")
load "local/config/deploy/#{fetch(:stage)}.rb" if File.exist?("local/config/deploy/#{fetch(:stage)}.rb")

set :deploy_to, "/var/www/rails/#{fetch(:application)}"

set :repo_url, "git://github.com/scottwillson/racing_on_rails.git"
set :site_local_repo_url, "git@github.com:scottwillson/#{fetch(:application)}-local.git"

set :user, "app"

namespace :deploy do
  desc "Deploy association-specific customizations"
  task :local_code do
    on roles :app do
      if fetch(:application) != "racing_on_rails"
        if fetch(:site_local_repo_url_branch)
          execute :git, "clone #{fetch(:site_local_repo_url)} -b #{fetch(:site_local_repo_url_branch)} #{release_path}/local"
        else
          execute :git, "clone #{fetch(:site_local_repo_url)} #{release_path}/local"
        end
        execute :chmod, "-R g+w #{release_path}/local"
        execute :ln, "-s #{release_path}/local/public #{release_path}/public/local"
      end
    end
  end

  task :registration_engine do
    on roles :app do
      if fetch(:application) == "obra" || fetch(:application) == "nabra"
        if test("[ -e \"#{release_path}/lib/registration_engine\" ]")
          execute :rm, "-rf \"#{release_path}/lib/registration_engine\""
        end

        if test("[ -L \"#{release_path}/lib/registration_engine\" ]")
          execute :rm, "-rf \"#{release_path}/lib/registration_engine\""
        end

        execute :git, "clone git@github.com:scottwillson/registration_engine.git #{release_path}/lib/registration_engine"
      end
    end
  end

  task :copy_cache do
    on roles :app do
      %w{ bar bar.html events export people index.html results results.html teams teams.html }.each do |cached_path|
        run("if [ -e \"#{previous_release}/public/#{cached_path}\" ]; then cp -pr #{previous_release}/public/#{cached_path} #{release_path}/public/#{cached_path}; fi") rescue nil
      end
    end
  end

  task :cache_error_pages do
    on roles :app do
      %w{ 404 422 500 503 }.each do |status_code|
        execute :curl, "--silent --fail http://#{fetch :app_hostname}/#{status_code} -o #{release_path}/public/#{status_code}.html"
      end
    end
  end
end

before "deploy:updated", "deploy:local_code"
before "deploy:updated", "deploy:registration_engine"
after "deploy:updated", "deploy:copy_cache"
after "deploy:finished", "deploy:cache_error_pages"
