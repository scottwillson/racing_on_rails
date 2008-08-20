require 'net/http'
require 'rubygems'
require 'test/unit'
require 'yaml'
require 'rake/packagetask'

include Test::Unit::Assertions

namespace :racing_on_rails do
  
  desc 'Copy release package to web server' 
  task :deploy_release do
    puts(`scp pkg/racing_on_rails-0.0.7.zip butlerpress.com:public_html/racing_on_rails/downloads/racing_on_rails.0.0.7.zip`)
    puts(`scp pkg/racing_on_rails-0.0.7.tar.gz butlerpress.com:public_html/racing_on_rails/downloads/racing_on_rails.0.0.7.tar.gz`)
  end

  desc "Package, deploy new app from scratch. Test."
  task :dist => [:dump_schema, :repackage, :create_app, :acceptence] do
  end

  desc "User acceptence test for end users and developers"
  task :acceptence => [:create_app] do
    puts('acceptence_user')
    run_acceptence_user(File.expand_path('~/racing_on_rails-0.0.7'))
    puts('customize')
    customize
    puts('acceptence_developer')
    run_acceptence_developer(File.expand_path('~/racing_on_rails-0.0.7'))
  end

  task :create_app do
    app_path = File.expand_path('~/racing_on_rails-0.0.7')
    rm_rf app_path
  
    puts(`tar zxf pkg/racing_on_rails-0.0.7.tar.gz -C ~`)
    `mysql -u root racing_on_rails_development < /db/schema.sql`
  end

  desc 'Customize new app'
  task :customize do
    # Config
    customize("config/environment.rb")

    # Views
    customize("app/views/home/index.rhtml")
    customize("app/views/schedule/index.rhtml")

    # Extend Helpers, Controller, Model, Routes, Lib
    customize("app/helpers/schedule_helper.rb")
    customize("app/controllers/home_controller.rb")
    customize("app/models/single_day_event.rb")
    # TODO Add custom lib class

    # Create whole slice (view, controller, model, helper, lib) for 'shops'

    # Override instance and class methods of AR
    # And in superclasses, then reference in subclass

    path = File.expand_path('~/racing_on_rails-0.0.7')
    puts(`#{path}/script/generate model BikeShop`)
    puts(`#{path}/script/generate controller BikeShops list`)
    customize('script/create_bike_shops_table.rb')
    puts(`ruby #{path}/script/create_bike_shops_table.rb`)
    customize("app/views/bike_shops/list.rhtml")
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

      response = Net::HTTP.get('127.0.0.1', '/bike_shops/list', 3000)
      assert_match('Sellwood Cycle Repair', response, "Sellwood on bike shops list page \n#{response}")
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

  def customize(fixture_path)
    mkpath(File.dirname(File.expand_path("~/racing_on_rails-0.0.7/#{fixture_path}")))
    cp(File.expand_path("/test/fixtures/#{fixture_path}"),
       File.expand_path("~/racing_on_rails-0.0.7/#{fixture_path}"))
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
  
  Rake::PackageTask.new("racing_on_rails", "0.0.7") do |p|
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
