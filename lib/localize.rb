# Local config customization
load("#{RAILS_ROOT}/local/config/environment.rb") if File.exist?("#{RAILS_ROOT}/local/config/environment.rb")
load("#{RAILS_ROOT}/local/config/environments/#{RAILS_ENV}.rb") if File.exist?("#{RAILS_ROOT}/local/config/environments/#{RAILS_ENV}.rb")

# Prefer local templates, partials etc. if they exist.  Otherwise, use the base
# application's generic files.

ActionController::Base.view_paths.insert(0, File.expand_path("#{RAILS_ROOT}/local/app/views"))
