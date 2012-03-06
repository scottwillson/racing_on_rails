load "deploy"
load "config/deploy"
require "capistrano-unicorn"

roles.clear
role :app, "bushtit.obra.org"
role :db, "bushtit.obra.org", :primary => true
set :user, "app"

set :rails_env, "production"
set :deploy_to, "/var/www/rails/#{application}"
