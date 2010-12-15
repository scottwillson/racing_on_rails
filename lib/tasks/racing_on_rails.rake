namespace :racing_on_rails do
  
  desc 'Cold setup' 
  task :bootstrap do
    puts "Bootstrap task will delete your Racing on Rails development database."
    db_password = ask("MySQL root password (press return for no password): ")
    puts "Create databases"
    puts `mysql -u root #{db_password_arg(db_password)} < #{File.expand_path(::Rails.root.to_s + "/db/create_databases.sql")}`
    puts "Populate development database"
    puts `mysql -u root #{db_password_arg(db_password)} racing_on_rails_development -e "SET FOREIGN_KEY_CHECKS=0; source #{File.expand_path(::Rails.root.to_s + "/db/development_structure.sql")}; SET FOREIGN_KEY_CHECKS=1;"`
    Rake::Task["db:fixtures:load"].invoke
    puts "Start server"
    puts "Please open http://localhost:3000/ in your web browser"
    puts `ruby script/server`
  end
end

desc "Override default cc.rb task, mainly to NOT try and recreate the test DB from migrations"
task :cruise do
  ENV['CC_BUILD_ARTIFACTS'] = File.expand_path("#{::Rails.root.to_s}/log/acceptance")

  # Use Xvfb to create an X session for browser-based acceptance tests
  if RUBY_PLATFORM[/freebsd/] || RUBY_PLATFORM[/linux/]
    ENV['DISPLAY'] = "localhost:1"
    if `ps aux | grep "Xvfb :1" | grep -v grep`.blank?
      xvfb_pid = fork do
        exec("Xvfb :1 -screen 0 1024x768x24")
      end
      Process.detach(xvfb_pid)
    end
  end
  
  Rake::Task["db:migrate"].invoke
  Rake::Task["db:test:prepare"].invoke
  Rake::Task["test:units"].invoke
  Rake::Task["test:functionals"].invoke
  Rake::Task["test:integration"].invoke
  
  begin
    Rake::Task["test:acceptance:browser"].invoke
  ensure
    if RUBY_PLATFORM[/freebsd/]
      # Rake task doesn't seem to quit Firefox correctly
      fork do
        exec("killall firefox-bin")
      end
    end
    # Wait for Firefox to exit
    Process.wait
  end
end

namespace :db do
  namespace :structure do
    desc "Monkey-patched by Racing on Rails. Standardize format to prevent source control churn."
    task :dump => :environment do
      sql = File.open("#{::Rails.root.to_s}/db/#{::Rails.env}_structure.sql").readlines.join
      sql.gsub!(/AUTO_INCREMENT=\d+ +/i, "")

      File.open("#{::Rails.root.to_s}/db/#{::Rails.env}_structure.sql", "w") do |file|
        file << sql
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
  task :upload => [:clobber_app, :app] do
    `scp -r doc/app/ butlerpress.com:/usr/local/www/www.butlerpress.com/racing_on_rails/rdoc`
  end
end
