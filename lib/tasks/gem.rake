require 'net/http'
require 'rubygems'
require 'rake/gempackagetask'
require 'test/unit'

task :default => [
        :prepare,
        :gem,
        :uninstall_gem, 
        :install_gem,
        :create_app,
        :go_to_homepage
]

task :prepare do
  rm_rf 'pkg'
end

task :uninstall_gem do
  begin
    `sudo gem uninstall racingonrails`
  rescue
    put('uninstall gem failed')
  end
end

task :install_gem do
  `sudo gem install -l pkg/racingonrails-0.1`
end

task :create_app do
  racingonrails '~/bike_racing_association'
end

task :go_to_homepage do
  response = Net::HTTP.get('localhost', '/', 3000)
  assert(response['Bicycle Racing Association'], 'Homepage should be available')
end

spec = Gem::Specification.new do |s|
  s.name = 'racingonrails'
  s.version = '0.1'
  s.author = 'Scott Willson'
  s.email = 'scott@butlerpress.com'
  s.platform = Gem::Platform::RUBY
  s.summary = "Bicycle racing association event schedule and race results"
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList['public/index.html', 'bin/racingonrails'].to_a
  s.autorequire = 'rails'
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
