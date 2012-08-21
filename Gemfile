source 'https://rubygems.org'

gem "rails", "~>3.0.0"

gem "fastercsv", :platforms => :ruby_18
gem "rack", "~>1.2.3"
gem "rake"
gem "authlogic"
gem "tabular", ">0.0.5"
gem "mysql2", "<0.3.0"
gem "pdf-reader", :require => "pdf/reader"
gem "Ascii85", :require => "ascii85"
gem "prawn", :git => "git://github.com/sandal/prawn.git"
gem "vestal_versions", :git => "git://github.com/scottwillson/vestal_versions.git", :branch => "no_updated_by"
gem "newrelic_rpm"
gem "erubis"
gem "will_paginate", "~> 3.0.beta"
gem "airbrake"
gem "ruby-ole", :git => "git://github.com/scottwillson/ruby-ole.git"
gem "spreadsheet", :git => "git://github.com/scottwillson/spreadsheet.git"
gem "ri_cal"
gem "truncate_html"
gem "jquery-rails"

group :development do
  gem "capistrano"
  gem "capistrano-unicorn"
end

group :test do
  gem "factory_girl"
  gem "factory_girl_rails"
  gem "mocha", :require => false
  gem "sqlite3"
  gem "timecop"
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

group :production do
  gem "syslog-logger"
  gem "unicorn"
end
