require 'rake/packagetask'

namespace :racing_on_rails do
  
  desc 'Cold setup' 
  task :bootstrap do
    puts "Bootstrap task will delete your Racing on Rails development database."
    db_password = ask("MySQL root password (press return for no password): ")
    puts "Create databases"
    puts `mysql -u root #{db_password_arg(db_password)} < #{File.expand_path(RAILS_ROOT + "/db/create_databases.sql")}`
    puts "Populate development database"
    puts `mysql -u root #{db_password_arg(db_password)} racing_on_rails_development -e "SET FOREIGN_KEY_CHECKS=0; source #{File.expand_path(RAILS_ROOT + "/db/development_structure.sql")}; SET FOREIGN_KEY_CHECKS=1;"`
    Rake::Task["db:fixtures:load"].invoke
    puts "Start server"
    puts `ruby script/server`
  end
end

desc "Override default cc.rb task, mainly to NOT try and recreate the test DB from migrations"
task :cruise do
  if RUBY_PLATFORM[/freebsd/]
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
  
  begin
    Rake::Task["test:acceptance"].invoke
    # Clean up downloads
    FileUtils.rm Dir.glob("#{File.expand_path('~')}/lynx*.ppl")
    FileUtils.rm Dir.glob("#{File.expand_path('~')}/racers*.xls")
    FileUtils.rm Dir.glob("#{File.expand_path('~')}/scoring_sheet*.xls")
    FileUtils.rm Dir.glob("#{File.expand_path('~')}/scoring_sheet*.xls")
    FileUtils.rm Dir.glob("#{File.expand_path('~')}/lynx*.xls")
    FileUtils.rm Dir.glob("#{File.expand_path('~')}/Downloads/racers*.xls")
    FileUtils.rm Dir.glob("#{File.expand_path('~')}/Downloads/scoring_sheet*.xls")
    FileUtils.rm Dir.glob("#{File.expand_path('~')}/Downloads/lynx*.xls")
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
    desc "Monkey-patched by Racing on Rails. Standardize format to prevent SVN churn."
    task :dump do
      sql = File.open("#{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql").readlines.join
      sql.gsub!(/AUTO_INCREMENT=\d+ +/i, "")
      sql.downcase!
      
      File.open("#{RAILS_ROOT}/db/#{RAILS_ENV}_structure.sql", "w") do |file|
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