source "https://rubygems.org"

gem "rails", ">=3.2.12"

gem "fastercsv", :platforms => :ruby_18
gem "oj"
gem "rake"
gem "authlogic"
gem "tabular", ">0.2.0"
gem "mysql2"
gem "pdf-reader", :require => "pdf/reader"
gem "Ascii85", :require => "ascii85"
gem "prawn", :github => "sandal/prawn"
gem "vestal_versions", :github => "scottwillson/vestal_versions", :branch => "rails_3_2"
gem "newrelic_rpm"
gem "erubis"
gem "will_paginate", "~> 3.0.beta"
gem "ruby-ole", :github => "scottwillson/ruby-ole"
gem "spreadsheet", :github => "scottwillson/spreadsheet"
gem "ckeditor_rails", :require => "ckeditor-rails"
gem "default_value_for", :git => "https://github.com/FooBarWidget/default_value_for"
gem "acts_as_list", :github => "swanandp/acts_as_list", :ref => "f62c43265f0e47fe7666a93849abad5aa7c5c6d3"
gem "acts_as_tree", :github => "parasew/acts_as_tree"
gem "dynamic_form"
gem "in_place_editing"
gem "ri_cal"
gem "truncate_html"
gem "jquery-rails"
gem "yui-compressor"
gem 'therubyracer', "~> 0.10.2"
gem "libv8"
gem "activemerchant"
gem "registration_engine", :path => "lib/registration_engine"
gem "carrierwave"
gem "rmagick"
gem "formatize"
gem "json", ">= 1.7.7"
gem "nokogiri"

group :assets do
  gem "sass-rails",   "~> 3.2"
  gem "coffee-rails", "~> 3.2"
  gem "uglifier", ">= 1.0.3"
end

group :development do
  gem "capistrano"
  gem "capistrano-unicorn", :require => false
  gem "quiet_assets"
end

group :test do
  gem "factory_girl"
  gem "factory_girl_rails"
  gem "mocha", :require => false
  gem "sqlite3"
  gem "timecop"
  gem "minitest", "< 5.0.0"
end

group :acceptance do
  gem "capybara"
  gem "database_cleaner"
  gem "factory_girl"
  gem "factory_girl_rails"
  gem "launchy"
  gem "mocha", :require => false
  gem "selenium-webdriver"
  gem "timecop"
end

group :staging do
  gem "execjs"
  gem "rvm-capistrano"
  gem "capistrano-unicorn", :require => false
end

group :production do
  gem "airbrake"
  gem "syslog-logger"
  gem "unicorn"
  gem "execjs"
end
