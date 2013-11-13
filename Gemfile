source "https://rubygems.org"

gem "rails", ">=3.2.12"

gem "activemerchant"
gem "acts_as_list", :github => "swanandp/acts_as_list", :ref => "f62c43265f0e47fe7666a93849abad5aa7c5c6d3"
gem "acts_as_tree", :github => "parasew/acts_as_tree"
gem "Ascii85", :require => "ascii85"
gem "authlogic"
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass", "~> 2.3.2"
gem "carrierwave"
gem "chronic", "< 0.10.0"
gem "ckeditor_rails", :require => "ckeditor-rails"
gem "default_value_for", :github => "FooBarWidget/default_value_for"
gem "erubis"
gem "redcarpet"
gem "in_place_editing"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "json", ">= 1.7.7"
gem "money", :github => "RubyMoney/money"
gem "mysql2"
gem "newrelic_rpm"
gem "nokogiri"
gem "oj"
gem "pdf-reader", :require => "pdf/reader"
gem "prawn", :github => "sandal/prawn"
gem "rake"
gem "raygun4ruby"
gem "registration_engine", :path => "lib/registration_engine"
gem "ri_cal"
gem "rmagick"
gem "ruby-ole", :github => "scottwillson/ruby-ole"
gem "spreadsheet", :github => "scottwillson/spreadsheet"
gem "strong_parameters"
gem "tabular", ">=0.2.4"
gem "truncate_html"
gem "vestal_versions", :github => "scottwillson/vestal_versions", :branch => "rails_3_2"
gem "will_paginate"
gem "will_paginate-bootstrap", "0.2.5"
gem "yui-compressor"

group :assets do
  gem "coffee-rails", "~> 3.2"
  gem "sass-rails",   "~> 3.2"
  gem "uglifier", ">= 1.0.3"
end

group :development do
  gem "capistrano"
  gem "capistrano-unicorn", :require => false
  gem "quiet_assets"
end

group :test do
  gem "factory_girl_rails"
  gem "minitest", "~> 4.0"
  gem "mocha", :require => false
  gem "timecop"
end

group :acceptance do
  gem "capybara"
  gem "database_cleaner"
  gem "execjs"
  gem "factory_girl_rails"
  gem "launchy"
  gem "mocha", :require => false
  gem "selenium-webdriver"
  gem "therubyracer"
  gem "timecop"
end

group :staging do
  gem "capistrano-unicorn", :require => false
  gem "execjs"
  gem "rvm-capistrano"
  gem "therubyracer"
end

group :production do
  gem "execjs"
  gem "syslog-logger"
  gem "therubyracer"
  gem "unicorn"
end
