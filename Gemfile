# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "~> 4.2"

gem "activemerchant", "1.78.0"
gem "acts_as_list"
gem "acts_as_tree", git: "https://github.com/amerine/acts_as_tree.git"
gem "Ascii85", require: "ascii85"
gem "authlogic", "< 4.0.0"
gem "axlsx", git: "https://github.com/randym/axlsx.git"
gem "axlsx_rails", ">=0.4"
gem "bcrypt"
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass"
gem "capistrano"
gem "capistrano-bundler"
gem "carrierwave"
gem "chronic", "< 0.10.0"
gem "ckeditor"
gem "coffee-rails", "~> 4.0"
gem "coffee-script-source", "~> 1.7"
gem "damerau-levenshtein"
gem "default_value_for"
gem "erubis"
gem "hashdiff"
gem "in_place_editing"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "mini_magick"
gem "money"
gem "mysql2", "< 0.4"
gem "newrelic_rpm"
gem "nokogiri"
gem "oj"
gem "paper_trail"
gem "parallel_tests"
gem "pdf-reader", require: "pdf/reader"
gem "prawn", git: "https://github.com/sandal/prawn.git"
gem "puma"
gem "rails-observers", "= 0.1.2"
gem "rake"
gem "redcarpet"
gem "rest-client", ">= 2.0.0.rc1"
gem "ri_cal"
# Roo versions after 2.1.1 break fractional seconds in Excel import, and 2.1.1 has warnings in Rubby 2.4
gem "roo", git: "https://github.com/scottwillson/roo.git", branch: "v2.1.1-ruby-2-4"
gem "roo-xls"
gem "ruby-ole"
# Security update
gem "rubyzip", ">= 1.2.1"
gem "sass-rails", "~> 5"
gem "scrypt"
gem "spreadsheet"
gem "stripe"
gem "tabular", ">= 0.4.2"
gem "truncate_html"
gem "uglifier"
gem "vestal_versions", git: "https://github.com/scottwillson/vestal_versions.git"
gem "will_paginate", "~> 3.0"
gem "will_paginate-bootstrap", git: "https://github.com/estately/will_paginate-bootstrap.git"
gem "yui-compressor"
gem "zip-zip"

# Require after WillPaginate
gem "elasticsearch-model"
gem "elasticsearch-rails"

group :development do
  gem "brakeman"
  gem "bullet"
  gem "bundler-audit"
  gem "capistrano-rails"
  gem "capistrano-rvm"
  gem "capistrano3-puma"
  gem "celluloid-benchmark"
  gem "rubocop", require: false
  gem "spring"
end

group :development, :test do
  gem "quiet_assets"
end

group :test do
  gem "capybara"
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "fakeweb", git: "https://github.com/chrisk/fakeweb.git"
  gem "minitest", "~> 5.4"
  gem "mocha", require: false
  gem "poltergeist"
  gem "selenium-webdriver"
  gem "simplecov"
  gem "timecop"
end

group :staging, :production do
  gem "connection_pool"
  gem "dalli"
  gem "execjs"
  gem "logstash-logger"
  gem "raygun4ruby", "~> 1.1"
  gem "therubyracer"
end
