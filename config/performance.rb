load "deploy"
load "config/deploy"
load "config/db"
load "local/config/performance.rb" if File.exists?("local/config/performance.rb")

set :rails_env, "performance"
