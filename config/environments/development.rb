RacingOnRails::Application.configure do
  config.action_controller.action_on_unpermitted_parameters = :raise
  config.action_controller.perform_caching                  = ENV["PERFORM_CACHING"] || false
  config.action_mailer.raise_delivery_errors                = false
  config.active_record.migration_error                      = :page_load
  config.active_support.deprecation                         = :log
  config.assets.css_compressor                              = false
  config.assets.debug                                       = true
  config.assets.js_compressor                               = false
  config.assets.raise_runtime_errors                        = true
  config.cache_classes                                      = ENV["CACHE_CLASSES"] || false
  config.consider_all_requests_local                        = true
  config.eager_load                                         = false
  config.middleware.use                                       Rack::LiveReload
  config.action_view.raise_on_missing_translations          = true

  config.after_initialize do
    Bullet.enable = ENV["BULLET"] || false
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.stacktrace_includes = [ 'registration' ]
  end
end
