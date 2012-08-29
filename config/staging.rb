set :rails_env, "staging"

load "deploy"
load "config/deploy"
load "config/db"
load "local/config/staging.rb" if File.exists?("local/config/staging.rb")

require "rvm/capistrano"
set :rvm_ruby_string, 'ruby-1.9.3-p194@staging'

namespace :deploy do
  task :robots do
    run "echo \"User-Agent: *\nDisallow: /\n\" > #{release_path}/public/robots.txt"
  end
end

after "deploy:update_code", "deploy:robots"
