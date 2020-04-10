# frozen_string_literal: true

Rails.application.config.assets.paths << Rails.root.join("node_modules")
Rails.application.config.assets.version = "6.0"

Rails.application.configure do
  config.assets.precompile += %w[
    admin.js
    apple-touch-icon.png
    ckeditor/config.js
    favicon.ico
    racing_association.css
    racing_association.js
    registration_engine/application.js
  ]
  config.assets.precompile << ["*.png", "*.jpg"]
end
