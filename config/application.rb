require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

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
      #{config.root}/lib/sentient_user
    )

    config.encoding = "utf-8"

    config.session_store :key, "_racing_on_rails_session"
    config.session_store :secret, "9998d23d32c59a8161aba78b03630a93"
    
    config.assets.enabled = true
    config.assets.version = '1.0'
  
    config.time_zone = "Pacific Time (US & Canada)"
    
    # Racing on Rails has many foreign key constraints, so :sql is required
    config.active_record.schema_format = :sql
  
    unless ENV["SKIP_OBSERVERS"]
      config.active_record.observers = :event_observer, :name_observer, :person_observer, :race_observer, :result_observer, :team_observer
    end
  
    config.filter_parameters += [ :password, :password_confirmation ]
  
    # HP's proxy, among others, gets this wrong
    config.action_dispatch.ip_spoofing_check = false
    
    # Ugh. Make config accessible to overrides
    @config = config
    
    if File.exist?("#{config.root}/local/config/environments/#{::Rails.env}.rb")
      load("#{config.root}/local/config/environments/#{::Rails.env}.rb")
    end
    
    # See Rails::Configuration for more options
    if File.exists?("#{config.root}/local/config/database.yml")
      paths.config.database = "#{config.root}/local/config/database.yml"
    end
  end
  
  # Local config customization
  load("#{::Rails.root.to_s}/local/config/environment.rb") if File.exist?("#{::Rails.root.to_s}/local/config/environment.rb")
  
  class ActionView::Base
    def self.default_form_builder
      RacingOnRails::FormBuilder
    end
  end
end
