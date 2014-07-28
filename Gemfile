source "https://rubygems.org"

gem "rails", "4.1.4"

gem "actionpack-page_caching"
gem "activemerchant"
gem "acts_as_list", git: "https://github.com/swanandp/acts_as_list.git", ref: "ac4f602d20b679370ed4bb9702ccc3fa61af1be8"
gem "acts_as_tree", git: "https://github.com/amerine/acts_as_tree.git"
gem "Ascii85", require: "ascii85"
gem "authlogic"
gem "bcrypt"
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass"
gem "carrierwave"
gem "chronic", "< 0.10.0"
gem "ckeditor_rails", require: "ckeditor-rails"
gem "coffee-rails"
gem "dalli"
gem "default_value_for"
gem "erubis"
gem "in_place_editing"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "money"
gem "mysql2"
gem "newrelic_rpm"
gem "nokogiri"
gem "oj"
gem "pdf-reader", require: "pdf/reader"
gem "prawn", git: "https://github.com/sandal/prawn.git"
gem "rake"
gem "redcarpet"
gem "registration_engine", path: "lib/registration_engine"
gem "ri_cal"
gem "rmagick", require: false
gem "ruby-ole", git: "https://github.com/scottwillson/ruby-ole.git"
gem "sass-rails", "~> 4.0.3"
gem "scrypt"
gem "spreadsheet", git: "https://github.com/scottwillson/spreadsheet.git"
gem "tabular", ">=0.2.4"
gem "truncate_html"
gem "uglifier"
gem "vestal_versions", git: "https://github.com/scottwillson/vestal_versions.git", branch: "rails-4-1"
gem "will_paginate", git: "https://github.com/mislav/will_paginate"
gem "will_paginate-bootstrap"
gem "yui-compressor"

group :development do
  gem "brakeman"
  gem "bundler-audit"
  gem "capistrano"
  gem "capistrano-unicorn", require: false
  gem "guard-livereload", require: false
  gem "puma"
  gem "rubocop", require: false
  gem "rack-livereload"
  gem "spring"
end

group :development, :test do
  gem "quiet_assets"
end

group :test do
  gem "minitest"
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

group :production do
  gem "syslog-logger"
end

group :staging, :production do
  gem "raygun4ruby"
  gem "therubyracer"
  gem "unicorn"
end

group :acceptance, :staging, :production do
  gem "execjs"
  gem "rvm-capistrano"
end
