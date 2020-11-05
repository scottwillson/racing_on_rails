# frozen_string_literal: true

Rails.application.configure do
  config.action_controller.action_on_unpermitted_parameters = :raise
  config.action_controller.perform_caching                  = ENV["PERFORM_CACHING"] || false
  config.action_mailer.default_url_options                  = { host: "localhost", port: 3000 }
  config.action_mailer.delivery_method                      = :test
  config.action_mailer.perform_caching                      = false
  config.action_mailer.raise_delivery_errors                = false
  config.action_view.raise_on_missing_translations          = true
  config.active_record.migration_error                      = :page_load
  config.active_record.verbose_query_logs                   = true
  config.active_storage.service                             = :local
  config.active_support.deprecation                         = :raise
  config.assets.debug                                       = true
  config.assets.quiet                                       = true
  config.cache_classes                                      = ENV["CACHE_CLASSES"] || false
  config.consider_all_requests_local                        = true
  config.eager_load                                         = false
  config.file_watcher                                       = ActiveSupport::EventedFileUpdateChecker

  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.after_initialize do
    Bullet.enable = ENV["BULLET"] || false
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.stacktrace_includes = ["registration"]
  end
end
