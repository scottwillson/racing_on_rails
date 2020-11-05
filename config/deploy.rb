# frozen_string_literal: true

lock "3.12.1"

set :linked_dirs, %w[ log public/assets public/system public/uploads tmp/pids tmp/cache tmp/sockets vendor/bundle ]
set :linked_files, %w[ config/database.yml config/newrelic.yml config/master.key config/puma.rb ]

set :bundle_jobs, 4
set :bundle_without, %w[ development test ]

load "local/config/deploy.rb" if File.exist?("local/config/deploy.rb")
load "local/config/deploy/#{fetch(:stage)}.rb" if File.exist?("local/config/deploy/#{fetch(:stage)}.rb")

set :deploy_to, "/var/www/rails/#{fetch(:application)}"

set :repo_url, "git://github.com/scottwillson/racing_on_rails.git"
set :site_local_repo_url, "git@github.com:scottwillson/#{fetch(:application)}-local.git"

set :puma_conf, "#{shared_path}/config/puma.rb"

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
        execute :rm, "-rf \"#{release_path}/lib/registration_engine\"" if test("[ -e \"#{release_path}/lib/registration_engine\" ]")
        execute :rm, "-rf \"#{release_path}/registration_engine\"" if test("[ -e \"#{release_path}/registration_engine\" ]")

        execute :rm, "-rf \"#{release_path}/lib/registration_engine\"" if test("[ -L \"#{release_path}/lib/registration_engine\" ]")
        execute :rm, "-rf \"#{release_path}/registration_engine\"" if test("[ -L \"#{release_path}/registration_engine\" ]")

        execute :git, "clone git@github.com:scottwillson/registration_engine.git -b rails-6 #{release_path}/registration_engine"
      end
    end
  end

  task :cache_error_pages do
    on roles :app do
      %w[ 404 422 500 503 ].each do |status_code|
        execute :curl, "--silent --fail --retry 1 http://#{fetch :app_hostname}/#{status_code} -o #{release_path}/public/#{status_code}.html"
      end
    end
  end
end

task :compress_assets_7z do
  on roles(:app) do
    assets_path = release_path.join("public", fetch(:assets_prefix))
    execute "find -L #{assets_path} \\( -name *.js -o -name *.css -o -name *.ico \\) -exec bash -c '[ ! -f {}.gz ] && 7z a -tgzip -mx=9 {}.gz {}' \\;"
  end
end

after "deploy:normalize_assets", "compress_assets_7z"
before "deploy:updated", "deploy:local_code"
before "deploy:updated", "deploy:registration_engine"
after "deploy:finished", "deploy:cache_error_pages"
