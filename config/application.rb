require File.expand_path("../boot", __FILE__)

require "rails/all"

Bundler.require(*Rails.groups)

module RacingOnRails
  class Application < Rails::Application
    config.autoload_paths += %W(
      #{config.root}/app/pdfs
      #{config.root}/app/models/observers
      #{config.root}/app/rack
    )

    config.encoding = "utf-8"

    config.assets.enabled = true
    config.assets.version = "1.1"

    config.time_zone = "Pacific Time (US & Canada)"

    I18n.config.enforce_available_locales = true

    # Racing on Rails has many foreign key constraints, so :sql is required
    config.active_record.schema_format = :sql

    unless ENV["SKIP_OBSERVERS"]
      config.active_record.observers = :event_observer, :name_observer, :person_observer, :race_observer, :team_observer
    end

    # HP's proxy, among others, gets this wrong
    config.action_dispatch.ip_spoofing_check = false

    require "#{config.root}/app/helpers/racing_on_rails/form_builder"
    config.action_view.default_form_builder = ::RacingOnRails::FormBuilder

    # Production database config handled by Ansible
    if !Rails.env.production? && !Rails.env.staging? && File.exist?("#{config.root}/local/config/database.yml")
      Rails.configuration.paths["config/database"] = [ "local/config/database.yml", "config/database.yml" ]
    end

    config.action_mailer.default_url_options = { mobile: nil }

    config.cache_store = :mem_cache_store

    def exception_notifier
      if Rails.env.production? || Rails.env.staging?
        Raygun
      else
        require "exception_notification/logging"
        ExceptionNotification::Logging
      end
    end
  end
end
