# frozen_string_literal: true

Rails.application.config.assets.paths << Rails.root.join("node_modules")
Rails.application.config.assets.paths << Rails.root.join("local/app/assets/images")
Rails.application.config.assets.paths << Rails.root.join("local/app/assets/javascripts")
Rails.application.config.assets.paths << Rails.root.join("local/app/assets/stylesheets")

# Rails.application.config.assets.paths << Rails.root.join("lib/registration_engine/app/assets/images")
# Rails.application.config.assets.paths << Rails.root.join("lib/registration_engine/app/assets/javascripts")
# Rails.application.config.assets.paths << Rails.root.join("lib/registration_engine/app/assets/stylesheets")

Rails.application.config.assets.version = "6.0"
