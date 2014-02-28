source "https://rubygems.org"

gem "rails", ">=3.2.12"

gem "activemerchant"
gem "acts_as_list", :git => "https://github.com/swanandp/acts_as_list.git"
gem "acts_as_tree", :git => "https://github.com/parasew/acts_as_tree.git"
gem "Ascii85", :require => "ascii85"
gem "authlogic"
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass", "~> 2.3.2"
gem "carrierwave"
gem "chronic", "< 0.10.0"
gem "ckeditor_rails", :require => "ckeditor-rails"
gem "default_value_for"
gem "erubis"
gem "redcarpet"
gem "in_place_editing"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "json", ">= 1.7.7"
gem "money"
gem "mysql2"
gem "newrelic_rpm"
gem "nokogiri"
gem "oj"
gem "pdf-reader", :require => "pdf/reader"
gem "prawn", :git => "https://github.com/sandal/prawn.git"
gem "rake"
gem "raygun4ruby"
gem "registration_engine", :path => "lib/registration_engine"
gem "ri_cal"
gem "rmagick", :require => false
gem "ruby-ole", :git => "https://github.com/scottwillson/ruby-ole.git"
gem "spreadsheet", :git => "https://github.com/scottwillson/spreadsheet.git"
gem "strong_parameters"
gem "tabular", ">=0.2.4"
gem "truncate_html"
gem "vestal_versions", :git => "https://github.com/scottwillson/vestal_versions.git", :branch => "rails_3_2"
gem "will_paginate"
gem "will_paginate-bootstrap", "0.2.5"
gem "yui-compressor"

group :assets do
  gem "coffee-rails", "~> 3.2"
  gem "sass-rails",   "~> 3.2"
  gem "uglifier"
end

group :development do
  gem "brakeman"
  gem "bundler-audit"
  gem "capistrano"
  gem "capistrano-unicorn", :require => false
  gem "quiet_assets"
end

group :test do
  gem "minitest", "~> 4.7"
end

group :acceptance do
  gem "capybara"
  gem "database_cleaner"
  gem "launchy"
  gem "selenium-webdriver"
end

group :test, :acceptance do
  gem "factory_girl_rails"
  gem "mocha", :require => false
  gem "timecop"
end

group :production do
  gem "syslog-logger"
  gem "unicorn"
end

group :acceptance, :staging, :production do
  gem "execjs"
  gem "rvm-capistrano"
  gem "therubyracer"
end
