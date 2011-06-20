# Prefer local templates, partials etc. if they exist.  Otherwise, use the base
# application's generic files.
ActiveSupport.on_load(:action_controller) do
  view_paths.each do |path|
    prepend_view_path "#{::Rails.root.to_s}/local/app/views"
  end
end
