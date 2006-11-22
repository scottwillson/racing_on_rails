# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.1.6'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

LOCAL_ROOT = File.join(RAILS_ROOT, 'local')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :action_web_service ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  #
  # Racing on Rails has many foreign key constraints, so :sql is required
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :bar_sweeper, :home_sweeper, :schedule_sweeper

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  if File.exists?("#{RAILS_ROOT}/local/config/database.yml")
    config.database_configuration_file = "#{RAILS_ROOT}/local/config/database.yml"
  end
end

Inflector.inflections do |inflect|
   inflect.singular 'standings', 'standings'
   inflect.plural   'standings', 'standings'
end

# Include your application configuration below

require 'localize'
ActionController::Routing::Routes.reload

ActiveRecord::Base.colorize_logging = false

RACING_ON_RAILS_DEFAULT_LOGGER = RAILS_DEFAULT_LOGGER unless defined?(RACING_ON_RAILS_DEFAULT_LOGGER)

unless defined?(ASSOCIATION)
  ASSOCIATION = RacingAssociation.new
  ASSOCIATION.name = 'Cascadia Bicycle Racing Association'
  ASSOCIATION.short_name = 'CBRA'
  ASSOCIATION.state = 'OR'

  SANCTIONING_ORGANIZATIONS = ["FIAC", "CBRA", "UCI", "USA Cycling"] unless defined?(SANCTIONING_ORGANIZATIONS)
end