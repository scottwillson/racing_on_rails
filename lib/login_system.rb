module LoginSystem 
  
  protected
  
  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights  
  # example:
  #
  #  # only allow nonbobs
  #  def authorize?(user)
  #    user.login != "bob@con-way.com"
  #  end
  def authorize?(user)
     true
  end
  
  # overwrite this method if you only want to protect certain actions of the controller
  # example:
  # 
  #  # don't protect the login and the about method
  #  def protect?(action)
  #    if ['action', 'about'].include?(action)
  #       return false
  #    else
  #       return true
  #    end
  #  end
  def protect?(action)
    true
  end
   
  # login_required filter. add 
  #
  #   before_filter :login_required
  #
  # This only checks to see if a user is logged in.  It does NOT check for certain roles.
  # To check for a specific role, see check_role method
  #   
  #   def authorize?(user)
  # 
  def login_required
    unless is_logged_in?
      flash[:warn] = "You must be logged in to do that."
      redirect_to :controller => '/account', :action => 'login'
    end
  end

  # overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation. 
  # the default action is to redirect to the login screen
  # example use :
  # a popup window might just close itself for instance
  def access_denied
    redirect_to :controller => "/account", :action =>"login"
  end  
  
  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session[:return_to] = request.request_uri
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    if session[:return_to].nil?
      redirect_to default
    else
      redirect_to session[:return_to]
      session[:return_to] = nil
    end
  end
  
  # Is the user logged in?
  def is_logged_in?
    @logged_in_user = User.find(session[:user_id]) if session[:user_id]
  end
  
  # Return the logged in user, if logged in
  def logged_in_user
    return @logged_in_user if is_logged_in?
  end
  
  def logged_in_user=(user)
    if !user.nil?
      session[:user_id] = user.id
      @logged_in_user = user
    end
  end
  
  # Makes the is_logged_in? and logged_in_user methods available as helper methods
  # to the views
  def self.included(base)
    base.send :helper_method, :is_logged_in?, :logged_in_user
  end
  
  # Check if the current logged in user has a role, if not, redirect to login
  # and flash a warning
  def check_role(role)
    unless is_logged_in?
      flash[:notice] = "Please login"
      store_location
      return redirect_to(:controller => '/account', :action => 'login')
    end
    
    unless logged_in_user.has_role?(role)
      flash[:warn] = "You do not have permission to do that"
      store_location
      redirect_to :controller => '/account', :action => 'login'
    end
  end
  
  # Check if the current logged in user has the role of Administrator. Useful as it's own method
  # to be used in controllers' before_filter as needed.
  def check_administrator_role
    check_role('Administrator')
  end

end