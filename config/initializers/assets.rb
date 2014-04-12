RacingOnRails::Application.configure do
  config.assets.precompile                += %w(
    admin.js
    glyphicons-regular.eot
    glyphicons-regular.svg
    glyphicons-regular.ttf
    glyphicons-regular.woff
    racing_association.css
    racing_association.js
    raygun.js
  )
end
