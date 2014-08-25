require File.expand_path("../boot", __FILE__)

require "rails/all"

Bundler.require(*Rails.groups)

module RacingOnRails
  class Application < Rails::Application
    config.autoload_paths += %W(
      #{config.root}/app/models/observers
      #{config.root}/app/pdfs
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

    if Rails.env.production? || Rails.env.staging?
      config.lograge.enabled = true
      config.lograge.formatter = Lograge::Formatters::Logstash.new
      config.lograge.custom_options = lambda do |event|
        { racing_association: RacingAssociation.current.short_name }
      end
    end

    ActiveSupport::Notifications.subscribe(/racing_on_rails/) do |name, start, finish, id, payload|
      Rails.logger.info JSON.dump(
        {
          name: name,
          start: start,
          duration: (finish - start),
          id: id,
          current_person_name: ::Person.current.try(:name),
          current_person_id: ::Person.current.try(:id)
        }.merge(payload)
      )
    end

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
