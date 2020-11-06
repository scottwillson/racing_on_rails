# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 6.0"

gem "activemodel-serializers-xml"
gem "acts_as_tree", git: "https://github.com/amerine/acts_as_tree.git"
gem "Ascii85", require: "ascii85"
gem "authlogic"
gem "bcrypt"
gem "bootsnap", ">= 1.4.2", require: false
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass"
gem "capistrano"
gem "capistrano-bundler"
gem "carrierwave"
gem "caxlsx", ">= 2.0.1"
gem "caxlsx_rails", ">=0.5.2"
gem "chronic"
gem "ckeditor"
gem "damerau-levenshtein"
gem "hashdiff", [">= 1.0.0.beta1", "< 2.0.0"]
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
gem "puma"
gem "rails-observers"
gem "rake"
gem "redcarpet"
gem "registration_engine", path: "registration_engine"
gem "rest-client"
gem "ri_cal"
gem "roo", github: "scottwillson/roo"
gem "roo-xls"
gem "ruby-ole"
# Security update
gem "rubyzip"
gem "sass-rails"
gem "scrypt"
gem "spreadsheet"
gem "tabular", "0.4.7"
gem "uglifier"
gem "will_paginate"
gem "will_paginate-bootstrap", git: "https://github.com/estately/will_paginate-bootstrap.git"
gem "yui-compressor"
gem "zip-zip"

# Require after WillPaginate
# Match deployed version
gem "elasticsearch", ">= 6", "< 7"
gem "elasticsearch-model", ">= 6", "< 7"
gem "elasticsearch-rails", ">= 6", "< 7"

group :development do
  gem "brakeman"
  gem "bullet"
  gem "bundler-audit", github: "rubysec/bundler-audit"
  gem "capistrano-rails"
  gem "capistrano-rvm"
  gem "capistrano3-puma"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rubocop", require: false
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
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
  gem "logstash-logger"
  gem "raygun4ruby"
end
