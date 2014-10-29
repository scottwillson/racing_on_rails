namespace :racing_on_rails do

  desc 'Cold setup'
  task :bootstrap do
    puts "Bootstrap task will delete your Racing on Rails development database."
    db_password = ask("MySQL root password (press return for no password): ")
    puts "Create databases"
    puts `mysql -u root #{db_password_arg(db_password)} -e 'drop database if exists racing_on_rails_development'`
    puts `mysql -u root #{db_password_arg(db_password)} < #{File.expand_path(::Rails.root.to_s + "/db/grants.sql")}`
    puts "Populate development database"
    puts `rake db:setup`
    puts "Create test database"
    puts `rake db:setup RAILS_ENV=test`
    puts "Start server"
    puts "Please open http://localhost:8080/ in your web browser"
    puts exec("./bin/rails s puma -p 8080")
  end
  
  task database_dump: :environment do
    db = ActiveRecord::Base.configurations
    puts `mysqldump -u #{db["production"]["username"]} -p#{db["production"]["password"]} -h #{db["production"]["host"]} --compress --ignore-table=#{db["production"]["database"]}.posts #{db["production"]["database"]} > db/production.sql`
    puts `mysqldump -u #{db["production"]["username"]} -p#{db["production"]["password"]} -h #{db["production"]["host"]} --compress --no-data #{db["production"]["database"]} posts >> db/production.sql`
  end
  
  namespace :competitions do
    desc "Save COMPETITION results as JSON for comparison"
    task :snapshot do
      competition_class = "Competitions::#{ENV['COMPETITION']}".safe_constantize
      discipline = ENV['DISCIPLINE'] || "Road"
      competition = competition_class.where(discipline: discipline).current_year.first
      FileUtils.mkdir_p "#{Rails.root}/tmp/competitions"
      file_path = "#{Rails.root}/tmp/#{competition_class.name.underscore}-#{discipline.underscore}.json"
      FileUtils.rm_rf file_path
      File.write file_path, JSON.generate(competition.as_json(nil))
    end
    
    desc "Compare COMPETITION snapshot with new results"
    task :diff do
      competition_class = "Competitions::#{ENV['COMPETITION']}".safe_constantize
      competition_class.calculate!
      discipline = ENV['DISCIPLINE'] || "Road"
      competition = competition_class.where(discipline: discipline).current_year.first
      file_path = "#{Rails.root}/tmp/#{competition_class.name.underscore}-#{discipline.underscore}.json"
      snapshot_results = JSON.parse(File.read(file_path))
      new_results = competition.as_json(nil)
      diff = HashDiff.best_diff(snapshot_results, new_results)
      diff.each do |line|
        p line
      end
    end
  end
end

def ask(message)
  print message
  STDIN.gets.chomp
end

def db_password_arg(db_password)
  if db_password.blank?
    ""
  else
    " --password=#{db_password}"
  end
end

namespace :doc do
  desc "Upload RDoc to WWW server"
  task upload: [:clobber_app, :app] do
    `scp -r doc/app/ butlerpress.com:/usr/local/www/www.butlerpress.com/racing_on_rails/rdoc`
  end
end
