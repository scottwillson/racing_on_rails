RacingOnRails::Application.configure do
  config.action_controller.perform_caching   = true
  config.action_dispatch.x_sendfile_header   = 'X-Accel-Redirect'
  config.action_mailer.delivery_method       = :sendmail
  config.action_mailer.raise_delivery_errors = true
  config.action_view.cache_template_loading  = true
  config.active_support.deprecation          = :notify
  config.assets.compile                      = false
  config.assets.compress                     = true
  config.assets.css_compressor               = :yui
  config.assets.digest                       = true
  config.assets.js_compressor                = :uglifier
  config.assets.precompile                  += %w( racing_association.js ie.css racing_association.css racing_association_ie.css admin.js )
  config.cache_classes                       = true
  config.consider_all_requests_local         = true
  config.i18n.fallbacks                      = true
  config.serve_static_assets                 = false
  config.whiny_nils                          = true
end
