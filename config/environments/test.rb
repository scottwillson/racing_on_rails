RacingOnRails::Application.configure do
  config.action_controller.action_on_unpermitted_parameters = :raise
  config.action_controller.allow_forgery_protection         = false
  config.action_controller.perform_caching                  = false
  config.action_dispatch.show_exceptions                    = false
  config.action_mailer.delivery_method                      = :test
  config.active_support.deprecation                         = :stderr
  config.autoload_paths                                    += %W(
    #{config.root}/lib/test
  )
  config.active_support.test_order = :random
  config.cache_classes                                      = true
  config.consider_all_requests_local                        = true
  config.active_support.deprecation                         = :raise
  config.eager_load                                         = false
  # For fastness. Change locally if you need debug logging to a problem.
  config.log_level                                          = ENV["LOG_LEVEL"] || :warn
  config.mass_assignment_sanitizer                          = :strict
  config.serve_static_files                                = true
  config.static_cache_control                               = "public, max-age=3600"
end
