require 'rake/packagetask'

namespace :racing_on_rails do
  
  desc 'Copy release package to web server' 
  task :deploy_release do
    puts(`scp pkg/racing_on_rails-0.0.7.zip butlerpress.com:public_html/racing_on_rails/downloads/racing_on_rails.0.0.7.zip`)
    puts(`scp pkg/racing_on_rails-0.0.7.tar.gz butlerpress.com:public_html/racing_on_rails/downloads/racing_on_rails.0.0.7.tar.gz`)
  end

  desc "Package, deploy new app from scratch. Test."
  task :dist => [:dump_schema, :repackage, :create_app, :acceptence] do
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
