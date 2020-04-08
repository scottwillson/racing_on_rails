# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 6.0.2"

gem "activemerchant"
gem "activemodel-serializers-xml"
gem "acts_as_list"
gem "acts_as_tree", git: "https://github.com/amerine/acts_as_tree.git"
gem "Ascii85", require: "ascii85"
gem "authlogic"
gem "bcrypt"
gem "bootsnap", ">= 1.1.0", require: false
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass"
gem "capistrano"
gem "capistrano-bundler"
gem "carrierwave"
gem "caxlsx", ">= 2.0.1"
gem "caxlsx_rails", ">=0.5.2"
gem "chronic"
gem "ckeditor"
gem "coffee-rails"
gem "coffee-script-source"
gem "damerau-levenshtein"
gem "default_value_for"
gem "erubis"
gem "hashdiff", [">= 1.0.0.beta1", "< 2.0.0"]
gem "i18n"
gem "in_place_editing"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "mini_magick", "> 4.9.4"
gem "mysql2"
gem "newrelic_rpm"
gem "nokogiri"
gem "oj"
gem "paper_trail"
gem "parallel_tests"
gem "pdf-reader", require: "pdf/reader"
gem "prawn", git: "https://github.com/sandal/prawn.git"
gem "puma"
gem "sprockets", "< 4"
gem "rails-observers"
gem "rake"
gem "redcarpet"
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
gem "stripe"
gem "tabular", "0.4.7"
gem "truncate_html"
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
  gem "capybara-screenshot"
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "minitest"
  gem "mocha", require: false
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "simplecov"
  gem "timecop"
  gem "webdrivers", ">= 3.9.1"
  gem "webmock"
end

group :staging, :production do
  gem "connection_pool"
  gem "dalli"
  gem "execjs"
  gem "libv8"
  gem "logstash-logger"
  gem "raygun4ruby"
  gem "therubyracer"
end
