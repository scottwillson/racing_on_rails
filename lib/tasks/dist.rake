require 'net/http'
require 'rubygems'
require 'rake/gempackagetask'
require 'test/unit'
require 'yaml'
require 'open4'

include Open4
include Test::Unit::Assertions

namespace :racing_on_rails do
  desc "Create Racing on Rails gem, install it, run new Rails app"
  task :dist => [
          :prepare,
          :gem,
          :uninstall_gem, 
          :install_gem,
          :create_app,
          :go_to_homepage
  ]
  
  task :prepare do
    rm_rf 'pkg'
    rm_rf File.expand_path('~/bike_racing_association')
  end
  
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
    puts(`racingonrails #{File.expand_path('~/bike_racing_association')}`)
  end
  
  desc "Start Webrick and test homepage"
  task :go_to_homepage do
    begin
  
      stdin = ''
      stdout = ''
      stderr = ''
  
      webrick = bg "#{File.expand_path('~/bike_racing_association/script/server')}", 0=>stdin, 1=>stdout, 2=>stderr
      sleep 6
  
      response = Net::HTTP.get('127.0.0.1', '/index.html', 3000)
      assert(response['Welcome aboard'], 'Homepage should be available')
    ensure
      if webrick
        puts(`kill #{webrick.pid}`)
        webrick.exit
      end
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
  s.files = FileList['public/index.html', 'bin/racingonrails'].to_a
  s.bindir = "bin"
  s.executables = ["racingonrails"]
  s.default_executable = "racingonrails"
  s.description = <<EOF
Rails website for bicycle racing associations. Event schedule, member management, 
race results, season-long competetion calculations. Look and feel can be customized.
EOF
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
