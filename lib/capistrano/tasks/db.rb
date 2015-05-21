namespace :db do
  desc "Refreshes your local development environment from {stage}"
  task data_refresh: [ :database_dump, :remote_db_download, :data_load, :remote_db_cleanup ]

  # Dump the current database to a MySQL file
  task :database_dump do
    on roles(:db) do
      execute :mkdir, "-p #{deploy_to}/current/db"
      execute "/bin/bash --login -c 'cd #{deploy_to}/current; /usr/bin/env bundle exec #{deploy_to}/current/bin/rake racing_on_rails:database_dump RAILS_ENV=#{fetch(:stage)}'"
      execute :rm, "-f #{deploy_to}/current/db/#{fetch(:stage)}.sql.bz2"
      execute :bzip2, "#{deploy_to}/current/db/#{fetch(:stage)}.sql"
    end
  end

  # Downloads db/{stage}_data.sql from the remote environment to your local machine
  task :remote_db_download do
    on roles(:db) do
      system "mkdir -p tmp/db"
      system "rm -f tmp/db/#{fetch(:stage)}.sql.bz2"
      download! "#{deploy_to}/current/db/#{fetch(:stage)}.sql.bz2", "tmp/db/#{fetch(:stage)}.sql.bz2"
    end
  end

  # Load the data downloaded into db/{stage}}_data.sql into your local development database
  # By default, delete downloaded SQL. To keep it, set SAVE=true. Example:
  # cap production data_refresh SAVE=true
  task :data_load do
    on roles(:db) do
      require_relative "../../../config/environment.rb"
      db = ActiveRecord::Base.configurations
      dev_db = db[::Rails.env]["database"]
      `mysql -u #{db[::Rails.env]["username"]} -e 'drop database if exists #{dev_db}'`
      `mysql -u #{db[::Rails.env]["username"]} -e 'create database #{dev_db}'`
      if File.exist?("tmp/db/#{fetch(:stage)}.sql.bz2")
        system "rm -f tmp/db/#{fetch(:stage)}.sql" if File.exist?("tmp/db/#{fetch(:stage)}.sql")
        system "bzip2 -d tmp/db/#{fetch(:stage)}.sql.bz2"
      end
      `mysql -u #{db[::Rails.env]["username"]} #{dev_db} < tmp/db/#{fetch(:stage)}.sql`
      system("rm tmp/db/#{fetch(:stage)}.sql") if File.exist?("tmp/db/#{fetch(:stage)}.sql") && ENV["SAVE"].nil?
    end
  end

   # Cleans up data dump file
  task :remote_db_cleanup do
    on roles(:db) do
      execute :rm, "-f db/#{fetch(:stage)}.sql.bz2"
    end
  end
end
