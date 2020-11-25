# frozen_string_literal: true

require "capistrano/setup"

require "capistrano/deploy"
require "capistrano/rails"
require "capistrano/bundler"

require "capistrano/rvm"

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require "capistrano/rails/assets"
require "capistrano/rails/migrations"

require "capistrano/puma"
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Workers

Dir.glob("lib/capistrano/tasks/*.rb").each { |r| import r }
