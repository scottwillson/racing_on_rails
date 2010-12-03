config.cache_classes = true
config.whiny_nils = true

config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true

config.action_controller.allow_forgery_protection    = false
config.action_mailer.delivery_method = :test

config.gem "rubyzip", :lib => "zip/zip"
config.gem "ffi", :version => "0.6.3"
config.gem "childprocess"
config.gem "json_pure", :lib => "json"
config.gem "selenium-webdriver"
config.gem "mocha"
config.gem "minitest", :lib => "minitest/unit"
