namespace :db do
  desc "Refreshes your local development environment to the current production database" 
  task :production_data_refresh do
    db.database_dump
    db.remote_db_download
    db.production_data_load
    db.remote_db_cleanup
  end 

  # Dump the current database to a MySQL file
  task :database_dump, :roles => :db, :only => { :primary => true } do
    run("rm -f db/production.sql") if File.exists?("db/production.sql") 
    run("rm -f db/production.sql.bz2") if File.exists?("db/production.sql.bz2") 
    load File.expand_path("../../config/environment.rb", __FILE__)
    abcs = ActiveRecord::Base.configurations
    run("mkdir -p db")
    run("mysqldump -u #{abcs["production"]["username"]} -p#{abcs["production"]["password"]} --compress --ignore-table=#{abcs["production"]["database"]}.posts #{abcs["production"]["database"]} > db/production.sql")
     run("mysqldump -u #{abcs["production"]["username"]} -p#{abcs["production"]["password"]} --compress --no-data #{abcs["production"]["database"]} posts >> db/production.sql")
    run("rm -f db/production.sql.bz2")
    run("bzip2 db/production.sql")
  end

  # Downloads db/production_data.sql from the remote production environment to your local machine
  task :remote_db_download, :roles => :db, :only => { :primary => true } do
    system "rm -f db/production.sql.bz2"
    get "db/production.sql.bz2", "db/production.sql.bz2"
  end

  # Load the production data downloaded into db/production_data.sql into your local development database
  # By default, delete downloaded SQL. To keep it, set SAVE=true. Example:
  # cap production_data_refresh SAVE=true
  task :production_data_load, :roles => :db, :only => { :primary => true } do
    load File.expand_path("../../config/environment.rb", __FILE__)
    abcs = ActiveRecord::Base.configurations
    dev_db = abcs[RAILS_ENV]["database"]
    `mysql -u #{abcs[RAILS_ENV]["username"]} -e 'drop database if exists #{dev_db}'`
    `mysql -u #{abcs[RAILS_ENV]["username"]} -e 'create database #{dev_db}'`
    if File.exists?("db/production.sql.bz2")
      system "rm -f db/production.sql" if File.exists?("db/production.sql")
      system "bzip2 -d db/production.sql.bz2"
    end
    `mysql -u #{abcs[RAILS_ENV]["username"]} #{dev_db} < db/production.sql`
    exec("rm db/production.sql") if File.exists?("db/production.sql") && ENV["SAVE"].nil?
  end

   #Cleans up data dump file
  task :remote_db_cleanup, :roles => :db, :only => { :primary => true } do  
    run "rm db/production.sql.bz2"
  end 
end
