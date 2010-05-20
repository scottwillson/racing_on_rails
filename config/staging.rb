load "deploy"
load "config/deploy"
require 'mongrel_cluster/recipes'
load "config/db"
load "local/config/staging.rb" if File.exists?("local/config/staging.rb")

set :rails_env, "staging"

namespace :deploy do
  task :robots do
    run "echo \"User-Agent: *\nDisallow: /\n\" > #{release_path}/public/robots.txt"
  end
end

after "deploy:update_code", "deploy:local_code", "deploy:copy_cache", "deploy:robots"
