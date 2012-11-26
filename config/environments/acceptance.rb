RacingOnRails::Application.configure do
  config.action_controller.allow_forgery_protection = false
  config.action_controller.perform_caching          = false
  config.action_mailer.delivery_method              = :test
  config.active_support.deprecation                 = :stderr
  config.cache_classes                              = true
  config.consider_all_requests_local                = true
  config.whiny_nils                                 = true
end
