require 'net/http'
require 'rubygems'
require 'test/unit'
require 'yaml'
require 'rake/packagetask'

include Test::Unit::Assertions

namespace :racing_on_rails do
  
  desc 'Copy release package to web server' 
  task :deploy_release do
    puts(`scp pkg/racing_on_rails-0.0.3.zip butlerpress.com:public_html/racing_on_rails/downloads/racing_on_rails.zip`)
    puts(`scp pkg/racing_on_rails-0.0.3.tar.gz butlerpress.com:public_html/racing_on_rails/downloads/racing_on_rails.tar.gz`)
  end

  desc "Package, deploy new app from scratch. Test."
  task :dist => [:dump_schema, :repackage, :drop_development_databases, :create_app, :acceptence] do
  end

  desc 'Dump development schema'
  task :dump_schema do
    `mysqldump -u root --no-data racing_on_rails_development > #{RAILS_ROOT}/db/schema.sql`
  end
  
  desc 'Drop development and test databases'
  task :drop_development_databases do
    `mysql -u root -e 'drop database racing_on_rails_development'`
    `mysql -u root -e 'drop database racing_on_rails_test'`
  end

  # From production
  task :copy_production_schema do
    `mysql -u root -e 'drop database racing_on_rails_development'`
    `mysql -u root -e 'create database racing_on_rails_development'`
    `mysqldump -u obra --password=fenders -h db.obra.org --no-data obra | mysql -u root racing_on_rails_development`
  end

  # From production
  task :copy_production_data do
    `mysql -u root -e 'drop database racing_on_rails_development'`
    `mysql -u root -e 'create database racing_on_rails_development'`
    # Mailing list tables are large
    `mysqldump -u obra --password=fenders -h db.obra.org --no-data --databases obra --tables posts mailing_lists | mysql -u root racing_on_rails_development`                    
    `mysqldump -u obra --password=fenders -h db.obra.org --compress --ignore-table=obra.posts --ignore-table=obra.mailing_lists obra | mysql -u root racing_on_rails_development`
  end
  
  desc "User acceptence test for end users and developers"
  task :acceptence => [:create_app] do
    puts('acceptence_user')
    run_acceptence_user(integration_build_root)
    puts('customize')
    customize
    puts('acceptence_developer')
    run_acceptence_developer(integration_build_root)
  end

  task :create_app do
    app_path = File.expand_path(integration_build_root)
    rm_rf app_path
  
    puts(`tar zxf pkg/racing_on_rails-0.0.3.tar.gz`)
    mv 'racing_on_rails-0.0.3', integration_build_root
    `mysql -u root < db/create_databases.sql`
    `mysql -u root racing_on_rails_development < db/schema.sql`
  end

  desc 'Add a local app with custom code'
  task :customize do
    # Config
    customize("config/environment.rb", integration_build_root)

    # Views
    customize("app/views/home/index.rhtml", integration_build_root)
    customize("app/views/schedule/index.rhtml", integration_build_root)

    # Extend Helpers, Controller, Model, Routes, Lib
    customize("app/helpers/schedule_helper.rb", integration_build_root)
    customize("app/controllers/home_controller.rb", integration_build_root)
    customize("app/models/single_day_event.rb", integration_build_root)
    # TODO Add custom lib class

  end

  task :acceptence_developer do
    web_test do
      response = Net::HTTP.get('127.0.0.1', '/', 3000)
      assert_match('Northern California/Nevada Cycling Association', response, "Association name on homepage in \n#{response}")
      assert_no_match(/Error/, response, "No error on homepage \n#{response}")
      assert_no_match(/Application Trace/, response, "No error on homepage \n#{response}")
      assert_no_match(/<a href="results"/, response, "No results link in \n#{response}")
      assert_match('<a href="/schedule/2006"', response, "2006 schedule link should be available in \n#{response}")
      assert_match('<a href="/schedule/2005"', response, "2005 schedule link should be available in \n#{response}")
      assert_match('<a href="/schedule/2004"', response, "2004 schedule link should be available in \n#{response}")
      assert_match('Flash message from customized controller', response, "Custom controller flash message in \n#{response}")

      response = Net::HTTP.get('127.0.0.1', '/schedule/', 3000)
      assert_no_match(/Error/, response, "No error on homepage \n#{response}")
      assert_no_match(/Application Trace/, response, "No error on homepage \n#{response}")
      assert_match('January', response, "Months on schedule page \n#{response}")
      assert_match('December', response, "Months on schedule page \n#{response}")
      assert_match('until the 2010 Cherry Pie Road Race!!!', response, "Cherry Pie coutdown \n#{response}")
      assert_match('Custom Finder Event', response, "Custom Finder Event from cutomized SingleDayEvent class \n#{response}")
      assert_match('<i>Custom Finder Event</i>', response, "Custom Finder Event name from cutomized SingleDayEvent class \n#{response}")
    end
  end

  desc "Start Webrick and web interface"
  task :acceptence_user do
    web_test do
      response = Net::HTTP.get('127.0.0.1', '/', 3000)
      assert_match('Cascadia Bicycle Racing Association', response, "Homepage should be available in \n#{response}")
      assert_match('<a href="/schedule"', response, "Schedule link should be available in \n#{response}")
      assert_match('Upcoming Events', response, "Upcoming Events should be available in \n#{response}")

      response = Net::HTTP.get('127.0.0.1', '/schedule', 3000)
      assert_match('Schedule', response, "Schedule should be available in \n#{response}")
      assert_match('January', response, "Schedule should be available in \n#{response}")
      assert_match('December', response, "Schedule should be available in \n#{response}")

      response = Net::HTTP.get('127.0.0.1', '/schedule/list', 3000)

      # TODO Run unit and functional tests
      # TODO move above assertions into tests
      # TODO Validate HTML
    end
  end

  def customize(fixture_path, integration_build_root)
    mkpath(File.dirname(File.expand_path("#{integration_build_root}/#{fixture_path}")))
    cp(File.expand_path("test/fixtures/#{fixture_path}"),
       File.expand_path("#{integration_build_root}/#{fixture_path}"))
  end

  def web_test
    begin
      `mongrel_rails start -d`
      sleep 5
      yield
    ensure
      `mongrel_rails stop`
    end
  end
  
  def run_acceptence_developer(project_root = nil)
    if project_root
      exec("rake --rakefile #{project_root}/Rakefile racing_on_rails:acceptence_developer")
    else
      acceptence_developer
    end
  end
  
  def run_acceptence_user(project_root = nil)
    if project_root
      exec("rake --rakefile #{project_root}/Rakefile racing_on_rails:acceptence_user")
    else
      acceptence_user
    end
  end
  
  Rake::PackageTask.new("racing_on_rails", "0.0.3") do |p|
    p.need_tar_gz = true
    p.need_zip = true
    files = Dir.glob('**/*', File::FNM_DOTMATCH).reject do |f| 
       [ /\.$/,
         /\.log$/, 
         /^pkg/, 
         /\.svn/, 
         /^vendor\/rails/, 
         /\.tmproj/,
         /\.DS_Store/,
         /^public\/(files|xml|index.html)/,
         /\~$/, 
         /\/\._/, 
         /\/#/ ].any? {|regex| f =~ regex }
    end
    p.package_files.include(files)
  end
end
