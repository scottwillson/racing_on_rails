RAILS_GEM_VERSION = '=2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

if Gem::VERSION >= "1.3.6"
    module Rails
        class GemDependency
            def requirement
                r = super
                (r == Gem::Requirement.default) ? nil : r
            end
        end
    end
end

Rails::Initializer.run do |config|
  config.frameworks -= [ :action_web_service ]

  config.load_paths += %W( #{RAILS_ROOT}/app/rack #{RAILS_ROOT}/app/models/competitions )
  
  config.action_controller.session = {
    :key => '_racing_on_rails_session',
    :secret      => '9998d23d32c59a8161aba78b03630a93'
  }
  
  config.gem "authlogic", :version => "2.1.3"
  config.gem "fastercsv"
  config.gem "tabular", :version => "0.0.4"
  config.gem "color"
  config.gem "pdf-writer", :lib => "pdf/writer"
  config.gem "vestal_versions"
  config.gem "sentient_user"

  if RAILS_ENV == "acceptance"
    config.gem "selenium-webdriver"
    config.gem "mocha"
  end

  if RAILS_ENV == "test"
    config.gem "mocha"
  end

  config.time_zone = "Pacific Time (US & Canada)"
  
  # Racing on Rails has many foreign key constraints, so :sql is required
  config.active_record.schema_format = :sql

  config.active_record.observers = :event_observer, :result_observer

  # Ugh. Make config accessible to overrides
  @config = config
  
  if File.exist?("#{RAILS_ROOT}/local/config/environments/#{RAILS_ENV}.rb")
    load("#{RAILS_ROOT}/local/config/environments/#{RAILS_ENV}.rb")
  end
  
  # See Rails::Configuration for more options
  if File.exists?("#{RAILS_ROOT}/local/config/database.yml")
    config.database_configuration_file = "#{RAILS_ROOT}/local/config/database.yml"
  end
end

# Local config customization
load("#{RAILS_ROOT}/local/config/environment.rb") if File.exist?("#{RAILS_ROOT}/local/config/environment.rb")

# Prefer local templates, partials etc. if they exist.  Otherwise, use the base
# application's generic files.
ActionController::Base.view_paths = ActionView::Base.process_view_paths(["#{RAILS_ROOT}/local/app/views", "#{RAILS_ROOT}/app/views"])

class ActionView::Base
  def self.default_form_builder
    RacingOnRails::FormBuilder
  end
end

require "action_view/template_handlers/pdf_writer"
ActionView::Template.register_template_handler :pdf_writer, ActionView::TemplateHandlers::PDFWriter

require 'array'
require 'nil_class'
require 'string'
require "local_static"
require "action_view/inline_template_extension"

unless defined?(ASSOCIATION)
  ASSOCIATION = RacingAssociation.new
  ASSOCIATION.name = 'Cascadia Bicycle Racing Association'
  ASSOCIATION.short_name = 'CBRA'
  ASSOCIATION.state = 'OR'
  ASSOCIATION.rental_numbers = 51..99 if RAILS_ENV == 'test'
  
  SANCTIONING_ORGANIZATIONS = ["FIAC", "CBRA", "UCI", "USA Cycling"] unless defined?(SANCTIONING_ORGANIZATIONS)
end

RAILS_HOST  = 'localhost:3000' unless defined?(RAILS_HOST)
STATIC_HOST = 'localhost' unless defined?(STATIC_HOST)
ActionMailer::Base.default_url_options[:host] = RAILS_HOST

# Limit number of people, teams, etc. returned in search
SEARCH_RESULTS_LIMIT          = 100 unless defined?(SEARCH_RESULTS_LIMIT)

# Homepage display
WEEKS_OF_RECENT_RESULTS       = 2 unless defined?(WEEKS_OF_RECENT_RESULTS)
WEEKS_OF_UPCOMING_EVENTS      = 5 unless defined?(WEEKS_OF_UPCOMING_EVENTS)

SHOW_ALL_TEAMS_ON_PUBLIC_PAGE = false unless defined?(SHOW_ALL_TEAMS_ON_PUBLIC_PAGE)
