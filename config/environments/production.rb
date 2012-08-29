RacingOnRails::Application.configure do
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
  config.active_support.deprecation        = :notify
  config.assets.compile                    = false
  config.assets.compress                   = true
  config.assets.css_compressor             = :yui
  config.assets.digest                     = true
  config.assets.js_compressor              = :uglifier
  config.cache_classes                     = true
  config.consider_all_requests_local       = false
  config.i18n.fallbacks                    = true
  config.logger                            = Logger::Syslog.new("racing_on_rails", Syslog::LOG_LOCAL4)
  config.logger.level                      = ::Logger::INFO
  config.serve_static_assets               = false
  config.assets.precompile += %w( wsba.css tabs.js )
end
