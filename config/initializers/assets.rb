RacingOnRails::Application.configure do
  config.assets.precompile += %w(
    %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$)
    admin.js
    apple-touch-icon.png
    favicon.ico
    racing_association.css
    racing_association.js
  )
end
