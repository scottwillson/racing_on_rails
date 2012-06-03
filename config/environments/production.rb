RacingOnRails::Application.configure do
  config.cache_classes = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  config.assets.compress = true
  config.assets.css_compressor = :yui
  config.assets.js_compressor = :uglifier

  config.serve_static_assets = false
  config.assets.compile = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify
  
  config.logger = Logger::Syslog.new("racing_on_rails", Syslog::LOG_LOCAL4)
  config.logger.level = ::Logger::INFO
end
