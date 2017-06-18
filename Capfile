require 'capistrano/setup'

require 'capistrano/deploy'

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

require 'capistrano/puma'
require 'capistrano/rvm'

Dir.glob('lib/capistrano/tasks/*.rb').each { |r| import r }
