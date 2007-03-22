# 
# # desc 'Dump development schema'
# # task :dump_schema do
# #   `mysqldump -u root --no-data racing_on_rails_development > /db/schema.sql`
# # end
# # 
# # desc "Copy schema from production"
# # task :copy_production_schema do
# #   `mysql -u root -e 'drop database racing_on_rails_development'`
# #   `mysql -u root -e 'create database racing_on_rails_development'`
# #   `mysqldump -u obra --password=fenders -h db.obra.org --no-data obra > db/production_schema.sql`
# #   `mysql -u root racing_on_rails_development < db/production_schema.sql`
# # end
# # 
# # desc "Copy schema and data from production"
# # task :copy_production_data do
# #   `mysql -u root -e 'drop database racing_on_rails_development'`
# #   `mysql -u root -e 'create database racing_on_rails_development'`
# #   # Mailing list tables are large
# #   `mysqldump -u obra --password=fenders -h db.obra.org --no-data --databases obra --tables posts mailing_lists > db/production_data.sql`
# #   `mysqldump -u obra --password=fenders -h db.obra.org --compress --ignore-table=obra.posts --ignore-table=obra.mailing_lists obra >> db/production_data.sql`
# #   `mysql -u root racing_on_rails_development < db/production_data.sql`
# # end
# 
# namespace :db do
#   desc "Dump the current database to a MySQL file" 
#   task :database_dump do
#     if File.exists?("#{RAILS_ROOT}/local/config/database.yml")
#       load 'local/config/environment.rb'
#     else
#       load 'loca/config/environment.rb'
#     end
#     abcs = ActiveRecord::Base.configurations
#     case abcs[RAILS_ENV]["adapter"]
#     when 'mysql'
#       ActiveRecord::Base.establish_connection(abcs[RAILS_ENV])
#       File.open("db/#{RAILS_ENV}_data.sql", "w+") do |f|
#         if abcs[RAILS_ENV]["password"].blank?
#           f << `mysqldump -h #{abcs[RAILS_ENV]["host"]} -u #{abcs[RAILS_ENV]["username"]} #{abcs[RAILS_ENV]["database"]}`
#         else
#           f << `mysqldump -h #{abcs[RAILS_ENV]["host"]} -u #{abcs[RAILS_ENV]["username"]} -p#{abcs[RAILS_ENV]["password"]} #{abcs[RAILS_ENV]["database"]}`
#         end
#       end
#     else
#       raise "Task not supported by '#{abcs[RAILS_ENV]['adapter']}'" 
#     end
#   end
# 
#   desc "Refreshes your local development environment to the current production database" 
#   task :production_data_refresh do
#     `rake remote:exec ACTION=remote_db_runner --trace`
#     `rake db:production_data_load --trace`
#   end 
# 
#   desc "Loads the production data downloaded into db/production_data.sql into your local development database" 
#   task :production_data_load do
#     load 'config/environment.rb'
#     abcs = ActiveRecord::Base.configurations
#     case abcs[RAILS_ENV]["adapter"]
#     when 'mysql'
#       ActiveRecord::Base.establish_connection(abcs[RAILS_ENV])
#       if abcs[RAILS_ENV]["password"].blank?
#         `mysql -h #{abcs[RAILS_ENV]["host"]} -u #{abcs[RAILS_ENV]["username"]} #{abcs[RAILS_ENV]["database"]} < db/production_data.sql`
#       else
#         `mysql -h #{abcs[RAILS_ENV]["host"]} -u #{abcs[RAILS_ENV]["username"]} -p#{abcs[RAILS_ENV]["password"]} #{abcs[RAILS_ENV]["database"]} < db/production_data.sql`
#       end
#     else
#       raise "Task not supported by '#{abcs[RAILS_ENV]['adapter']}'" 
#     end
#   end
# 
#   desc 'Dumps the production database to db/production_data.sql on the remote server'
#   task :remote_db_dump, :roles => :db, :only => { :primary => true } do
#     run "cd #{deploy_to}/#{current_dir} && " +
#       "#{rake} RAILS_ENV=#{rails_env} db:database_dump --trace" 
#   end
# 
#   desc 'Downloads db/production_data.sql from the remote production environment to your local machine'
#   task :remote_db_download, :roles => :db, :only => { :primary => true } do  
#     execute_on_servers(options) do |servers|
#       self.sessions[servers.first].sftp.connect do |tsftp|
#         tsftp.get_file "#{deploy_to}/#{current_dir}/db/production_data.sql", "db/production_data.sql" 
#       end
#     end
#   end
# 
#   desc 'Cleans up data dump file'
#   task :remote_db_cleanup, :roles => :db, :only => { :primary => true } do  
#     delete "#{deploy_to}/#{current_dir}/db/production_data.sql" 
#   end 
# 
#   desc 'Dumps, downloads and then cleans up the production data dump'
#   task :remote_db_runner do
#     remote_db_dump
#     remote_db_download
#     remote_db_cleanup
#   end
# end
