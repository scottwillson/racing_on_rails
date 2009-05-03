load "deploy"
load "config/deploy"
require 'mongrel_cluster/recipes'
load "config/db"
load "local/config/staging.rb" if File.exists?("local/config/staging.rb")

set :rails_env, "staging"
