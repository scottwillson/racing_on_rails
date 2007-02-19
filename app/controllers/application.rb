# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include LoginSystem
  
  RESULTS_LIMIT = 100
  
  # FIXME: Use conditional to look in local first, RAILS_ROOT second
  def rescue_action_in_public(exception)
    logger.debug('custom rescue_action_in_public')
  	case exception
    when ActiveRecord::RecordNotFound, ::ActionController::RoutingError, ::ActionController::UnknownAction
      render(:file => local_or_default_file('404.html'), :status => "404 Not Found")
	  	
	  else
	  	render(:file => local_or_default_file('500.html'), :status => "500 Error")
	  	SystemNotifier.deliver_exception_notification(self, request, exception)
	  	
    end
  end
  
  def rescue_action_locally(exception)
    logger.debug('custom rescue_action_locally')
    self.rescue_action_in_public(exception)
  end
  
  protected
  def local_or_default_file(name)
    local_path = File.join(RAILS_ROOT, 'local', 'public', "#{name}")
    logger.debug("local_or_default_file #{local_path} exists? #{File.exist?(local_path)}")
    if File.exist?(local_path)
      local_path
    else
      logger.debug(File.join(RAILS_ROOT, 'public', "#{name}"))
      File.join(RAILS_ROOT, 'public', "#{name}")
    end
  end
end

