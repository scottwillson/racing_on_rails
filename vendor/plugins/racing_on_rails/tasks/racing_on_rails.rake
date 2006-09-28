require 'net/http'
require 'rubygems'
require 'test/unit'
require 'yaml'
require 'open4'
require 'rake/packagetask'

include Open4
include Test::Unit::Assertions

namespace :racing_on_rails do
  namespace :test do
    task :dist => [:repackage, :create_app, :acceptence]

    desc "User acceptence test for end users and developers"
    task :acceptence => [:acceptence_user, :acceptence_developer] do
      
    end

    task :create_app do
      app_path = File.expand_path('~/cbra')
      rm_rf app_path
      rm_rf File.expand_path('~/racing_on_rails-0.0.1')
    
      puts(`tar zxf ~/racing_on_rails-0.0.1.tar.gz -C ~`)
      mv  File.expand_path('~/racing_on_rails-0.0.1'), app_path
      `mysql -u root cbra_development < #{app_path}/db/schema.sql`
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
  
      path = File.expand_path('~/racing_on_rails-0.0.1')
      puts(`#{path}/script/generate model BikeShop`)
      puts(`#{path}/script/generate controller BikeShops list`)
      customize('script/create_bike_shops_table.rb')
      puts(`ruby #{path}/script/create_bike_shops_table.rb`)
      customize("app/views/bike_shops/list.rhtml")
    end

    task :acceptence_developer => [:create_app, :customize] do
      web_test do
        response = Net::HTTP.get('127.0.0.1', '/', 3000)
        assert(response['Northern California/Nevada Cycling Association'], "Association name on homepage in \n#{response}")
        assert_nil(response['Error'], "No error on homepage \n#{response}")
        assert_nil(response['Application Trace'], "No error on homepage \n#{response}")
        assert_nil(response['<a href="/results"'], "No results link in \n#{response}")
        assert(response['<a href="/schedule/2006"'], "2006 schedule link should be available in \n#{response}")
        assert(response['<a href="/schedule/2005"'], "2005 schedule link should be available in \n#{response}")
        assert(response['<a href="/schedule/2004"'], "2004 schedule link should be available in \n#{response}")
        assert(response['Flash message from customized controller'], "Custom controller flash message in \n#{response}")

        response = Net::HTTP.get('127.0.0.1', '/schedule/', 3000)
        assert_nil(response['Error'], "No error on schedule page \n#{response}")
        assert_nil(response['Application Trace'], "No error on schedule page \n#{response}")
        assert(response['January'], "Months on schedule page \n#{response}")
        assert(response['December'], "Months on schedule page \n#{response}")
        assert(response['until the 2010 Cherry Pie Road Race!!!'], "Cherry Pie coutdown \n#{response}")
        assert(response['Custom Finder Event'], "Custom Finder Event from cutomized SingleDayEvent class \n#{response}")
        assert(response['<i>Custom Finder Event</i>'], "Custom Finder Event name from cutomized SingleDayEvent class \n#{response}")

        response = Net::HTTP.get('127.0.0.1', '/bike_shops/list', 3000)
        assert(response['Sellwood Cycle Repair'], "Sellwood on bike shops list page \n#{response}")
      end
    end

    desc "Start Webrick and web interface"
    task :acceptence_user do
      web_test do
        response = Net::HTTP.get('127.0.0.1', '/', 3000)
        assert(response['Bicycle Racing Association'], "Homepage should be available in \n#{response}")
        assert(response['<a href="/schedule"'], "Schedule link should be available in \n#{response}")
        assert(response['Upcoming Events'], "Upcoming Events should be available in \n#{response}")

        response = Net::HTTP.get('127.0.0.1', '/schedule', 3000)
        assert(response['Schedule'], "Schedule should be available in \n#{response}")
        assert(response['January'], "Schedule should be available in \n#{response}")
        assert(response['December'], "Schedule should be available in \n#{response}")

        response = Net::HTTP.get('127.0.0.1', '/schedule/list', 3000)
    
        # TODO Run unit and functional tests
        # TODO move above assertions into tests
        # TODO Validate HTML
      end
    end

    def customize(fixture_path)
      mkpath(File.dirname(File.expand_path("~/cbra/#{fixture_path}")))
      cp(File.expand_path("vendor/plugins/racing_on_rails/test/fixtures/#{fixture_path}"),
         File.expand_path("~/cbra/#{fixture_path}"))
    end
  end

  def web_test
    begin
      stdin = ''
      stdout = ''
      stderr = ''

      webrick = bg File.expand_path("#{RAILS_ROOT}/script/server"), 0 => stdin, 1 => stdout, 2 => stderr
      sleep 20
  
      yield
  
    ensure
      if webrick
        puts(`kill #{webrick.pid}`)
        webrick.exit
      end
    end
  end
  
  Rake::PackageTask.new("racing_on_rails", "0.0.1") do |p|
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