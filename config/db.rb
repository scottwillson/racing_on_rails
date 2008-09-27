namespace :db do
  desc "Refreshes your local development environment to the current production database" 
  task :production_data_refresh do
    db.database_dump
    db.remote_db_download
    db.production_data_load
    db.remote_db_cleanup
  end 

  desc "Dump the current database to a MySQL file" 
  task :database_dump, :roles => :db, :only => { :primary => true } do
    load 'config/environment.rb'
    abcs = ActiveRecord::Base.configurations
    run("mysqldump -u #{abcs["production"]["username"]} -p#{abcs["production"]["password"]} --compress --ignore-table=#{abcs["production"]["database"]}.posts #{abcs["production"]["database"]} > db/production.sql")
    run("bzip2 db/production.sql")
  end

  desc 'Downloads db/production_data.sql from the remote production environment to your local machine'
  task :remote_db_download, :roles => :db, :only => { :primary => true } do
    get "db/production.sql.bz2", "db/production.sql.bz2"
  end

  desc "Loads the production data downloaded into db/production_data.sql into your local development database" 
  task :production_data_load, :roles => :db, :only => { :primary => true } do
    exec "bzip2 -d db/production.sql.bz2"
    load 'config/environment.rb'
    abcs = ActiveRecord::Base.configurations
    `mysql -u #{abcs[RAILS_ENV]["username"]} #{abcs[RAILS_ENV]["database"]} < db/production.sql`
    exec("rm db/production.sql")
  end

  desc 'Cleans up data dump file'
  task :remote_db_cleanup, :roles => :db, :only => { :primary => true } do  
    run "rm db/production.sql.bz2"
  end 
end
