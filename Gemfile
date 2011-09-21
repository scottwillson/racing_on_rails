source :gemcutter

gem "rails", "~>3.0.0"

gem "fastercsv", :platforms => :ruby_18
gem "rack", "~>1.2.3"
gem "rake", "~>0.8.0"
gem "authlogic"
gem "tabular", ">0.0.5"
gem "mysql2", "<0.3.0"
gem "pdf-reader", :require => "pdf/reader"
gem "Ascii85", :require => "ascii85"
gem "prawn", :git => "git://github.com/sandal/prawn.git"
gem "vestal_versions", :git => "git@github.com:scottwillson/vestal_versions.git"
gem "newrelic_rpm"
gem "erubis"
gem "will_paginate", "~> 3.0.beta"
gem "hoptoad_notifier"

group :development do
  gem "capistrano"
end

group :test do
  gem "ansi"
  gem "mocha"
  gem "minitest"
  gem "timecop"
end

group :acceptance do
  gem "selenium-webdriver"
end

group :production do
  gem "SyslogLogger", :require => "syslog_logger"
  gem "unicorn"
end
