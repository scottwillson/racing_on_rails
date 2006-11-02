# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include LoginSystem
  
  RESULTS_LIMIT = 100
  
  def rescue_action_in_public(exception)
  	case exception
    when ActiveRecord::RecordNotFound, ::ActionController::RoutingError, ::ActionController::UnknownAction
      render(:file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found")
	  	
	  else
	  	render(:file => "#{RAILS_ROOT}/public/500.html", :status => "500 Error")
	  	SystemNotifier.deliver_exception_notification(self, request, exception)
	  	
    end
  end
end
