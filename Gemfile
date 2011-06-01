source :gemcutter

gem "rails", "2.3.11"
gem "rake", "0.8.7"

gem "fastercsv", :platforms => :ruby_18
gem "rack", "~>1.1.0"
gem "authlogic"
gem "tabular", ">0.0.5"
gem "hoptoad_notifier"
gem "mysql2", "<0.3.0"
gem "pdf-reader", :require => "pdf/reader"
gem "Ascii85", :require => "ascii85"
gem "prawn"
gem "prawn-core", :require => "prawn/core"
gem "vestal_versions"
gem "newrelic_rpm"
gem "will_paginate"
gem "erubis"

group :test do
  gem "ansi"
  gem "mocha"
  gem "minitest"
  gem "selenium-webdriver"
  gem "timecop"
end

group :acceptance do
  # Selenium has specific requirements
  gem "selenium-webdriver"
  gem "rubyzip", :require => "zip/zip"
  gem "ffi", "0.6.3"
  gem "childprocess", "0.1.4"
  gem "json_pure", :require => "json"
  gem "mocha"
end

group :production do
  gem "SyslogLogger", :require => "syslog_logger"
  gem "unicorn"
end
