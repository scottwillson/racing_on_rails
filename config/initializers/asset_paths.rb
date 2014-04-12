RacingOnRails::Application.configure do
  config.assets.paths.insert 0, Rails.root.join("local", "app", "assets", "images")
  config.assets.paths.insert 0, Rails.root.join("local", "app", "assets", "javascripts")
  config.assets.paths.insert 0, Rails.root.join("local", "app", "assets", "stylesheets")
end

