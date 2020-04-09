# frozen_string_literal: true

Rails.application.configure do
  config.action_controller.action_on_unpermitted_parameters = :raise
  config.action_controller.allow_forgery_protection         = false
  config.action_controller.perform_caching                  = false
  config.action_dispatch.show_exceptions                    = false
  config.action_mailer.delivery_method                      = :test
  config.action_mailer.perform_caching                      = false
  config.active_storage.service                             = :test
  config.active_support.deprecation                         = :stderr
  config.active_support.test_order                          = :random
  config.cache_classes                                      = true
  config.consider_all_requests_local                        = true
  config.eager_load                                         = false
  config.mass_assignment_sanitizer                          = :strict
  config.public_file_server.enabled                         = true
  config.public_file_server.headers                         = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }
end
