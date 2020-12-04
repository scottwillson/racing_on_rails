# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RacingOnRails
  class Application < Rails::Application
    config.load_defaults 6.0

    config.encoding = "utf-8"

    # TODO: change this
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
    config.exceptions_app = routes

    Rack::MiniProfiler.config.snapshot_every_n_requests = 100
    Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemcacheStore

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
