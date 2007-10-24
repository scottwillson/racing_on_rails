# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include LoginSystem
  
  RESULTS_LIMIT = 100

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_racing_on_rails_session_id'
  
  def rescue_action_in_public(exception)
    logger.error("rescue_action_in_public #{exception}")
  	case exception
    when ActiveRecord::RecordNotFound, ::ActionController::RoutingError, ::ActionController::UnknownAction
      render(:file => local_or_default_file('404.html'), :status => "404 Not Found")
	  	
	  else
	  	render(:file => local_or_default_file('500.html'), :status => "500 Error")
	  	SystemNotifier.deliver_exception_notification(self, request, exception)
	  	
    end
  end
  
  def expire_cache
    if perform_caching
      FileUtils.rm_rf(File.join(RAILS_ROOT, 'public', 'results'))
      FileUtils.rm_rf(File.join(RAILS_ROOT, 'public', 'bar'))
      FileUtils.rm_rf(File.join(RAILS_ROOT, 'public', 'schedule'))
      FileUtils.rm(File.join(RAILS_ROOT, 'public', 'results.html'), :force => true)
      FileUtils.rm(File.join(RAILS_ROOT, 'public', 'schedule.html'), :force =>true)
      FileUtils.rm(File.join(RAILS_ROOT, 'public', 'index.html'), :force => true)
      FileUtils.rm(File.join(RAILS_ROOT, 'public', 'bar.html'), :force => true)
    end
  end
  
  protected
  def local_or_default_file(name)
    local_path = File.join(RAILS_ROOT, 'local', 'public', "#{name}")
    if File.exist?(local_path)
      local_path
    else
      File.join(RAILS_ROOT, 'public', "#{name}")
    end
  end
end

