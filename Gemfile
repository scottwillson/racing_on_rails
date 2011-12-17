source :gemcutter

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
gem "vestal_versions", :git => "git://github.com/scottwillson/vestal_versions.git"
gem "newrelic_rpm"
gem "erubis"
gem "will_paginate", "~> 3.0.beta"
gem "airbrake"
gem "ruby-ole", :git => "git://github.com/scottwillson/ruby-ole.git"
gem "spreadsheet", :git => "git://github.com/scottwillson/spreadsheet.git"
gem "fckeditor", :git => "git://github.com/scottwillson/fckeditor.git"
gem "mysql_big_table_migration", :git => "https://github.com/analog-analytics/mysql_big_table_migration"

group :development do
  gem "capistrano"
end

group :test do
  gem "ansi"
  gem "factory_girl", "2.3.1"
  gem "factory_girl_rails"
  gem "mocha", :require => false
  gem "sqlite3"
  gem "timecop"
end

group :acceptance do
  gem "capybara"
  gem "database_cleaner"
  gem "factory_girl", "2.3.1"
  gem "factory_girl_rails"
  gem "launchy"
  gem "mocha", :require => false
  gem "selenium-webdriver"
  gem "timecop"
end

group :production do
  gem "SyslogLogger", :require => "syslog_logger"
  gem "unicorn"
end
