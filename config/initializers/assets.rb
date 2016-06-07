RacingOnRails::Application.configure do
  config.assets.precompile += %w(
    admin.js
    apple-touch-icon.png
    favicon.ico
    racing_association.css
    racing_association.js
  )
  config.assets.precompile << %r(.*\.png$)
  config.assets.precompile << %r(.*\.jpg$)
end
