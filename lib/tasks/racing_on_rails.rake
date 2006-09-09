# TODO Move into racing_on_rails/lib

require 'net/http'
require 'rubygems'
require 'rake/gempackagetask'
require 'test/unit'
require 'yaml'
require 'open4'

include Open4
include Test::Unit::Assertions

namespace :racing_on_rails do

  task :reinstall_gem => [:gem, :uninstall_gem, :install_gem]
  task :dist_test => [:reinstall_gem, :create_app, :test_web]
  
  task :uninstall_gem do
    begin
      puts(`sudo gem uninstall  -a -i -x racingonrails`)
    rescue
      puts('uninstall gem failed')
    end
  end
  
  task :install_gem do
    puts(`sudo gem install -y -l pkg/racingonrails-0.1`)
  end
  
  task :create_app do
    rm_rf File.expand_path('~/bike_racing_association')
    puts(`racing_on_rails #{File.expand_path('~/bike_racing_association')}`)
  end
  
  task :customize do
    # Config
    cp(File.expand_path('test/fixtures/config/environment.rb'),
       File.expand_path('~/bike_racing_association/config/environment.rb'))
    
    # View
    # Helper (extend, create new)
    # Controller (extend, create new)
    # Model (extend, create new)
    # Routes
    # Lib (extend, create new)
  end
  
  task :test_customization => [:reinstall_gem, :create_app, :customize] do
    web_test do
      response = Net::HTTP.get('127.0.0.1', '/', 3000)
      assert(response['Northern California/Nevada Cycling Association'], "Association name on homepage in \n#{response}")
      assert(response['<a href="/results"'], "Results link should be available in \n#{response}")
      assert(response['<a href="/schedule"'], "Schedule link should be available in \n#{response}")
    end
  end
  
  def web_test
    begin
      stdin = ''
      stdout = ''
      stderr = ''

      webrick = bg "#{File.expand_path('~/bike_racing_association/script/server')}", 0=>stdin, 1=>stdout, 2=>stderr
      sleep 6
      
      yield
      
    ensure
      if webrick
        puts(`kill #{webrick.pid}`)
        webrick.exit
      end
    end
  end
  
  desc "Start Webrick and test homepage"
  task :test_web do
    web_test do
      response = Net::HTTP.get('127.0.0.1', '/', 3000)
      assert(response['Bicycle Racing Association'], "Homepage should be available in \n#{response}")
      assert(response['<a href="/results"'], "Results link should be available in \n#{response}")
      assert(response['<a href="/schedule"'], "Schedule link should be available in \n#{response}")

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
end
  
spec = Gem::Specification.new do |s|
  s.name = 'racingonrails'
  s.version = '0.1'
  s.author = 'Scott Willson'
  s.email = 'scott@butlerpress.com'
  s.platform = Gem::Platform::RUBY
  s.summary = "Bicycle racing association event schedule and race results"
  s.requirements << 'database (MySQL)'
  s.add_dependency('rails')
  s.require_path = 'lib'
  s.autorequire = 'racingonrails'
  s.files = FileList[
    'bin/racing_on_rails', 
    'app/controllers/*',
    'app/helpers/*',
    'app/models/*',
    'app/views/**/*',
    'config/routes.rb',
    'db/schema.rb',
    'lib/**/*',
    'public/images/backgrounds/*',
    'public/stylesheets/*'
  ].to_a
  s.bindir = "bin"
  s.executables = ["racing_on_rails"]
  s.description = <<EOF
Rails website for bicycle racing associations. Event schedule, member management, 
race results, season-long competition calculations. Customizable look and feel.
EOF
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
