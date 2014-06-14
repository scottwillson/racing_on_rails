RacingOnRails::Application.configure do
  config.action_controller.action_on_unpermitted_parameters = :raise
  config.action_controller.perform_caching                  = true
  config.action_dispatch.x_sendfile_header                  = "X-Accel-Redirect"
  config.active_record.dump_schema_after_migration          = false
  config.active_support.deprecation                         = :notify
  config.assets.compile                                     = false
  # config.assets.css_compressor                              = :yui
  config.assets.digest                                      = true
  # config.assets.js_compressor                               = :uglifier
  config.assets.version                                     = "2.0"
  config.cache_classes                                      = true
  config.consider_all_requests_local                        = false
  config.eager_load                                         = true
  config.i18n.fallbacks                                     = true
  config.logger                                             = Logger::Syslog.new("racing_on_rails", Syslog::LOG_LOCAL4)
  config.logger.level                                       = :info
  config.log_formatter                                      = ::Logger::Formatter.new
  config.serve_static_assets                                = false
end
