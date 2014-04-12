RacingOnRails::Application.configure do
  config.assets.precompile                += %w(
    admin.js
    racing_association.css
    racing_association.js
    raygun.js
  )
end
