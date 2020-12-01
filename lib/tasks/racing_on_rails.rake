# frozen_string_literal: true

namespace :racing_on_rails do
  desc "Cold setup"
  task bootstrap: :environment do
    puts "Bootstrap task will delete your Racing on Rails development database."
    db_password = ask("MySQL root password (press return for no password): ")
    puts "Create databases"
    puts `mysql -u root #{db_password_arg(db_password)} -e 'drop database if exists racing_on_rails_development'`
    puts `mysql -u root #{db_password_arg(db_password)} < #{File.expand_path("#{::Rails.root}/db/grants.sql")}`
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
    puts `mysqldump -u #{db[Rails.env]["username"]} -p#{db[Rails.env]["password"]} -h #{db[Rails.env]["host"]} --compress --single-transaction --ignore-table=#{db[Rails.env]["database"]}.posts #{db[Rails.env]["database"]} > db/#{Rails.env}.sql`
    puts `mysqldump -u #{db[Rails.env]["username"]} -p#{db[Rails.env]["password"]} -h #{db[Rails.env]["host"]} --compress --single-transaction --no-data #{db[Rails.env]["database"]} posts >> db/#{Rails.env}.sql`
  end
end

def ask(message)
  print message
  $stdin.gets.chomp
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
  task upload: %i[clobber_app app] do
    `scp -r doc/app/ butlerpress.com:/usr/local/www/www.butlerpress.com/racing_on_rails/rdoc`
  end
end
