load "deploy"
load "config/deploy"
require 'mongrel_cluster/recipes'
load "config/db"
load "local/config/staging.rb" if File.exists?("local/config/staging.rb")

set :repository, 'http://butlerpress.com/var/repos/racing_on_rails/branches/comatose'
set :local_repository, "svn+ssh://butlerpress.com/var/repos/#{application}/branches/comatose"
set :rails_env, "staging"



