# config/initializers/template_handler.rb
module ActionController
  module ImplicitRender
	alias_method :original_default_render, :default_render
	
	def default_render
	  # Try to find the template first
	  template_exists = begin
		template_exists?(action_name)
	  rescue => e
		Rails.logger.error "Error checking template: #{e.message}"
		false
	  end
	  
	  # Log useful debugging info
	  Rails.logger.info "Default render called for #{controller_name}##{action_name}"
	  Rails.logger.info "Format: #{request.format}, path: #{request.path}"
	  Rails.logger.info "Template exists? #{template_exists}"
	  
	  # Try standard render first
	  begin
		original_default_render
	  rescue ActionController::MissingExactTemplate => e
		Rails.logger.info "Caught MissingExactTemplate, handling format: #{request.format}"
		
		# Handle by format
		if request.format.html?
		  # Try rendering the template directly
		  if template_exists
			render action_name
		  else
			# Return a basic response
			render html: "<h1>#{controller_name.titleize} #{action_name.titleize}</h1><p>No template found.</p>".html_safe, status: :ok
		  end
		elsif request.format.json?
		  # Get the controller's main model name
		  model_name = controller_name.singularize
		  instance_var = instance_variable_get("@#{model_name}")
		  
		  if instance_var
			render json: instance_var
		  else
			render json: { error: "Resource not found" }, status: :not_found
		  end
		else
		  # Pass the error up if it's an unsupported format
		  raise e
		end
	  end
	end
  end
end
