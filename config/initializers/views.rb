# frozen_string_literal: true

# Prefer local templates, partials etc. if they exist.  Otherwise, use the base
# application's generic files.
# ActiveSupport.on_load(:action_controller) do
#   view_paths.each do |_path|
#     prepend_view_path "#{::Rails.root}/local/app/views"
#   end
# end
