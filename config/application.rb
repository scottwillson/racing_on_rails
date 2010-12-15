require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module RacingOnRails
  class Application < Rails::Application
    config.autoload_paths += %W( #{::Rails.root.to_s}/app/rack #{::Rails.root.to_s}/app/models/competitions #{::Rails.root.to_s}/app/models/observers #{::Rails.root.to_s}/app/pdfs )
    
    config.session_store :key, "_racing_on_rails_session"
    config.session_store :secret, "9998d23d32c59a8161aba78b03630a93"
  
    config.time_zone = "Pacific Time (US & Canada)"
    
    # Racing on Rails has many foreign key constraints, so :sql is required
    config.active_record.schema_format = :sql
  
    unless ENV["SKIP_OBSERVERS"]
      config.active_record.observers = :event_observer, :name_observer, :person_observer, :race_observer, :result_observer, :team_observer
    end
  
    config.filter_parameters += [:password]
  
    # Ugh. Make config accessible to overrides
    @config = config
    
    if File.exist?("#{::Rails.root.to_s}/local/config/environments/#{::Rails.env}.rb")
      load("#{::Rails.root.to_s}/local/config/environments/#{::Rails.env}.rb")
    end
    
    # See Rails::Configuration for more options
    if File.exists?("#{::Rails.root.to_s}/local/config/database.yml")
      paths.config.database = "#{::Rails.root.to_s}/local/config/database.yml"
    end
  end
  
  # Local config customization
  load("#{::Rails.root.to_s}/local/config/environment.rb") if File.exist?("#{::Rails.root.to_s}/local/config/environment.rb")
  
  # Prefer local templates, partials etc. if they exist.  Otherwise, use the base
  # application's generic files.
  ActionController::Base.view_paths = ActionView::Base.process_view_paths(["#{::Rails.root.to_s}/local/app/views", "#{::Rails.root.to_s}/app/views"])
  
  class ActionView::Base
    def self.default_form_builder
      RacingOnRails::FormBuilder
    end
  end
end
