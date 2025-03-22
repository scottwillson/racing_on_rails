# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 6.1"

gem "activemodel-serializers-xml"
gem "acts_as_tree", git: "https://github.com/amerine/acts_as_tree.git"
gem "Ascii85", require: "ascii85"
gem "authlogic", github: "sudara/authlogic", branch: "rails6-1"
gem "bcrypt"
gem "bootsnap", ">= 1.4.2", require: false
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass"
gem "carrierwave"
gem "caxlsx", ">= 2.0.1"
gem "caxlsx_rails", ">=0.5.2"
gem "chronic"
gem "ckeditor"
gem "damerau-levenshtein"
# gem "google-api-client"
# gem "googleauth"
gem "hashdiff", [">= 1.0.0.beta1", "< 2.0.0"]
gem "highcharts-rails"
gem "hiredis"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "mini_magick", "> 4.9.4"
gem "mysql2"
gem "newrelic_rpm"
gem "nokogiri"
gem "oj"
gem "paper_trail"
gem "pdf-reader", require: "pdf/reader"
gem "prawn", git: "https://github.com/sandal/prawn.git"
gem "puma", "< 6"
gem "rails-observers"
gem "rake"
gem "redcarpet", ">= 3.5.1"
gem "registration_engine", path: "registration_engine"
gem "request_store_rails"
gem "rest-client"
gem "ri_cal"
gem "roo", github: "scottwillson/roo"
gem "roo-xls"
gem "ruby-ole"
gem "rubyzip"
gem "sass-rails"
gem "scrypt"
gem "spreadsheet"
gem "tabular", ">= 0.4.9"
gem "uglifier"
gem "will_paginate"
gem "will_paginate-bootstrap", git: "https://github.com/estately/will_paginate-bootstrap.git"
gem "yui-compressor"
gem "zip-zip"
gem "bcrypt_pbkdf", "~> 1.0", require: false, platforms: [:mri, :mingw, :x64_mingw]
gem 'ed25519', '~> 1.2', require: false, platforms: [:mri, :mingw, :x64_mingw]
gem 'capistrano', '~> 3.17'
gem 'capistrano-rails', '~> 1.6'
gem 'capistrano-bundler', '~> 2.1'
gem 'capistrano-rvm', '~> 0.1'
gem "capistrano3-puma", "~> 5.2"

group :development do
  gem "brakeman"
  gem "bundler-audit", github: "rubysec/bundler-audit"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rubocop", require: false
  gem "rubocop-minitest"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rake"
  gem "web-console", ">= 3.3.0"
end

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
end

group :test do
  gem "capybara"
  gem "factory_bot_rails"
  gem "minitest"
  gem "mocha", require: false
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "timecop"
  gem "webdrivers", ">= 3.9.1"
  gem "webmock"
end

group :staging, :production do
  gem "connection_pool"
  gem "dalli"
  gem "execjs"
  gem "raygun4ruby"
  gem "sd_notify"
end
