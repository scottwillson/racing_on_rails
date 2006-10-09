require 'net/http'
require 'rubygems'
require 'test/unit'
require 'yaml'
require 'open4'
require 'rake/packagetask'

include Open4
include Test::Unit::Assertions

namespace :racing_on_rails do
  
  desc "Package, deploy new app from scratch. Test."
  task :dist => [:repackage, :create_app, :acceptence] do
  end

  desc "User acceptence test for end users and developers"
  task :acceptence => [:acceptence_user, :acceptence_developer] do
  end

  task :create_app do
    app_path = File.expand_path('~/racing_on_rails-0.0.2')
    rm_rf app_path
  
    puts(`tar zxf ~/racing_on_rails-0.0.2.tar.gz -C ~`)
    `mysql -u root racing_on_rails_development < #{app_path}/db/schema.sql`
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

    path = File.expand_path('~/racing_on_rails-0.0.2')
    puts(`#{path}/script/generate model BikeShop`)
    puts(`#{path}/script/generate controller BikeShops list`)
    customize('script/create_bike_shops_table.rb')
    puts(`ruby #{path}/script/create_bike_shops_table.rb`)
    customize("app/views/bike_shops/list.rhtml")
  end

  task :acceptence_developer => [:create_app, :customize] do
    web_test(File.expand_path('~/racing_on_rails-0.0.2')) do
      response = Net::HTTP.get('127.0.0.2', '/', 3000)
      assert_match('Northern California/Nevada Cycling Association', response, "Association name on homepage in \n#{response}")
      assert_no_match(/Error/, response, "No error on homepage \n#{response}")
      assert_no_match(/Application Trace/, response, "No error on homepage \n#{response}")
      assert_no_match(/<a href="results"/, response, "No results link in \n#{response}")
      assert_match('<a href="/schedule/2006"', response, "2006 schedule link should be available in \n#{response}")
      assert_match('<a href="/schedule/2005"', response, "2005 schedule link should be available in \n#{response}")
      assert_match('<a href="/schedule/2004"', response, "2004 schedule link should be available in \n#{response}")
      assert_match('Flash message from customized controller', response, "Custom controller flash message in \n#{response}")

      response = Net::HTTP.get('127.0.0.2', '/schedule/', 3000)
      assert_no_match(/Error/, response, "No error on homepage \n#{response}")
      assert_no_match(/Application Trace/, response, "No error on homepage \n#{response}")
      assert_match('January', response, "Months on schedule page \n#{response}")
      assert_match('December', response, "Months on schedule page \n#{response}")
      assert_match('until the 2010 Cherry Pie Road Race!!!', response, "Cherry Pie coutdown \n#{response}")
      assert_match('Custom Finder Event', response, "Custom Finder Event from cutomized SingleDayEvent class \n#{response}")
      assert_match('<i>Custom Finder Event</i>', response, "Custom Finder Event name from cutomized SingleDayEvent class \n#{response}")

      response = Net::HTTP.get('127.0.0.2', '/bike_shops/list', 3000)
      assert_match('Sellwood Cycle Repair', response, "Sellwood on bike shops list page \n#{response}")
    end
  end

  desc "Start Webrick and web interface"
  task :acceptence_user do
    web_test(File.expand_path('~/racing_on_rails-0.0.2')) do
      response = Net::HTTP.get('127.0.0.2', '/', 3000)
      assert_match('Cascadia Bicycle Racing Association', response, "Homepage should be available in \n#{response}")
      assert_match('<a href="/schedule"', response, "Schedule link should be available in \n#{response}")
      assert_match('Upcoming Events', response, "Upcoming Events should be available in \n#{response}")

      response = Net::HTTP.get('127.0.0.2', '/schedule', 3000)
      assert_match('Schedule', response, "Schedule should be available in \n#{response}")
      assert_match('January', response, "Schedule should be available in \n#{response}")
      assert_match('December', response, "Schedule should be available in \n#{response}")

      response = Net::HTTP.get('127.0.0.2', '/schedule/list', 3000)
  
      # TODO Run unit and functional tests
      # TODO move above assertions into tests
      # TODO Validate HTML
    end
  end

  def customize(fixture_path)
    mkpath(File.dirname(File.expand_path("~/racing_on_rails-0.0.2/#{fixture_path}")))
    cp(File.expand_path("vendor/plugins/racing_on_rails/test/fixtures/#{fixture_path}"),
       File.expand_path("~/racing_on_rails-0.0.2/#{fixture_path}"))
  end

  def web_test(root = RAILS_ROOT)
    begin
      stdin = ''
      stdout = ''
      stderr = ''

      webrick = bg File.expand_path("#{root}/script/server"), 0 => stdin, 1 => stdout, 2 => stderr
      sleep 20
  
      yield
  
    ensure
      if webrick
        puts(`kill #{webrick.pid}`)
        webrick.exit
      end
    end
  end
  
  Rake::PackageTask.new("racing_on_rails", "0.0.2") do |p|
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