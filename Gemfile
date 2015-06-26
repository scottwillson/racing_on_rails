source "https://rubygems.org"

gem "rails", "~> 4.1.11"

gem "activemerchant", "~> 1.44"
gem "acts_as_list", git: "https://github.com/swanandp/acts_as_list.git", ref: "ac4f602d20b679370ed4bb9702ccc3fa61af1be8"
gem "acts_as_tree", git: "https://github.com/amerine/acts_as_tree.git"
gem "Ascii85", require: "ascii85"
gem "authlogic"
gem "bcrypt"
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass"
gem "bundler"
gem "carrierwave"
gem "chronic", "< 0.10.0"
gem "ckeditor_rails", require: "ckeditor-rails"
gem "coffee-rails"
gem "coffee-script-source", "~> 1.7"
gem "default_value_for"
gem "erubis"
gem "hashdiff"
gem "in_place_editing"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "mini_magick"
gem "money"
gem "mysql2"
gem "newrelic_rpm"
gem "nokogiri"
gem "oj"
gem "pdf-reader", require: "pdf/reader"
gem "prawn", git: "https://github.com/sandal/prawn.git"
gem "puma"
gem "rails-observers"
gem "rake"
gem "redcarpet"
gem "ri_cal"
gem "roo", github: "roo-rb/roo"
gem "roo-xls", github: "roo-rb/roo-xls"
gem "ruby-ole", "~> 1.2", git: "https://github.com/scottwillson/ruby-ole.git"
gem "sass-rails"
gem "scrypt"
gem "spreadsheet"
gem "tabular", ">= 0.3.5"
gem "truncate_html"
gem "uglifier"
gem "vestal_versions", git: "https://github.com/scottwillson/vestal_versions.git", branch: "rails-4-1"
gem "will_paginate", "~> 3.0"
gem "will_paginate-bootstrap"
gem "yui-compressor"

# Require after WillPaginate
gem "elasticsearch-model"
gem "elasticsearch-rails"

group :development do
  gem "brakeman"
  gem "bullet"
  gem "bundler-audit"
  gem "capistrano-rails"
  gem "capistrano3-puma"
  gem "capistrano-rvm"
  gem "celluloid-benchmark", "~> 0.1.9"
  gem "rubocop", require: false
  gem "rack-livereload"
  gem "spring"
end

group :development, :test do
  gem "quiet_assets"
end

group :test do
  gem "minitest", "~> 5.4"
end

group :acceptance do
  gem "capybara"
  gem "poltergeist"
  gem "selenium-webdriver"
end

group :test, :acceptance do
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "fakeweb"
  gem "mocha", require: false
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
