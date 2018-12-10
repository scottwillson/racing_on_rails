# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RacingOnRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

module RacingOnRails
  class Application < Rails::Application
    config.autoload_paths += %W[
      #{config.root}/app/models/observers
      #{config.root}/app/pdfs
    ]

    config.encoding = "utf-8"

    config.assets.enabled = true
    config.assets.version = "2.0"

    config.time_zone = "Pacific Time (US & Canada)"

    I18n.config.enforce_available_locales = true

    config.active_record.observers = :event_observer, :name_observer, :person_observer, :race_observer, :team_observer unless ENV["SKIP_OBSERVERS"]

    # HP's proxy, among others, gets this wrong
    config.action_dispatch.ip_spoofing_check = false

    require "#{config.root}/app/helpers/racing_on_rails/form_builder"
    config.action_view.default_form_builder = ::RacingOnRails::FormBuilder

    # Production database config handled by Ansible
    if !Rails.env.production? && !Rails.env.staging? && File.exist?("#{config.root}/local/config/database.yml")
      Rails.configuration.paths["config/database"] = ["local/config/database.yml", "config/database.yml"]
    end

    config.action_mailer.default_url_options = { mobile: nil }

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      domain: "obra.org",
      user_name: "app",
      password: Rails.application.credentials.smtp_password,
      authentication: "plain",
      enable_starttls_auto: true
    }
    config.exceptions_app = routes

    require "#{config.root}/lib/registration_engine/lib/registration_engine/engine" if Dir.exist?("#{config.root}/lib/registration_engine")

    require_dependency "acts_as_tree/extensions"
    require_dependency "acts_as_tree/validation"

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
