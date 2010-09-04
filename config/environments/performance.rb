config.cache_classes = true
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true
config.action_view.debug_rjs                         = true

config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :test
