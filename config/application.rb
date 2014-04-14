require File.expand_path("../boot", __FILE__)

require "rails/all"

Bundler.require(*Rails.groups)

module RacingOnRails
  class Application < Rails::Application
    config.autoload_paths += %W(
      #{config.root}/app/models/competitions
      #{config.root}/app/models/observers
      #{config.root}/app/pdfs
      #{config.root}/app/rack
      #{config.root}/lib
      #{config.root}/lib/racing_on_rails
      #{config.root}/lib/results
    )

    config.encoding = "utf-8"

    config.session_store :key, "_racing_on_rails_session"
    config.session_store :secret, "9998d23d32c59a8161aba78b03630a93"

    config.assets.enabled = true
    config.assets.version = "1.1"

    config.time_zone = "Pacific Time (US & Canada)"

    I18n.config.enforce_available_locales = true

    # Racing on Rails has many foreign key constraints, so :sql is required
    config.active_record.schema_format = :sql

    config.action_controller.action_on_unpermitted_parameters = :raise

    unless ENV["SKIP_OBSERVERS"]
      config.active_record.observers = :event_observer, :name_observer, :person_observer, :race_observer, :result_observer, :team_observer
    end

    config.filter_parameters += [ :password, :password_confirmation ]

    # HP's proxy, among others, gets this wrong
    config.action_dispatch.ip_spoofing_check = false

    require "#{config.root}/app/helpers/racing_on_rails/form_builder"
    config.action_view.default_form_builder = ::RacingOnRails::FormBuilder

    require "array/each_row"
    require "array/stable_sort"

    if File.exists?("#{config.root}/local/config/database.yml")
      Rails.configuration.paths["config/database"] = [ "local/config/database.yml", "config/database.yml" ]
    end

    config.action_mailer.default_url_options = { mobile: nil }

    def exception_notifier
      if Rails.env.production? || Rails.env.staging?
        Raygun
      else
        RacingOnRails::ExceptionNotifier
      end
    end
  end
end
