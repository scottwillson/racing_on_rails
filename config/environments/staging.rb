RacingOnRails::Application.configure do
  require "syslog/logger"

  config.action_controller.action_on_unpermitted_parameters = :raise
  config.action_controller.perform_caching                  = true
  config.action_dispatch.x_sendfile_header                  = "X-Accel-Redirect"
  config.action_mailer.delivery_method                      = :sendmail
  config.action_mailer.raise_delivery_errors                = true
  config.action_view.cache_template_loading                 = true
  config.active_support.deprecation                         = :notify
  config.assets.compile                                     = false
  config.assets.css_compressor                              = :yui
  config.assets.digest                                      = true
  config.assets.js_compressor                               = :uglifier
  config.assets.version                                     = "2.0"
  config.cache_classes                                      = true
  config.consider_all_requests_local                        = true
  config.eager_load                                         = true
  config.i18n.fallbacks                                     = true
  config.log_level                                          = :info
  config.logger                                             = Syslog::Logger.new("racing_on_rails", Syslog::LOG_LOCAL4)
  config.serve_static_assets                                = false
end
