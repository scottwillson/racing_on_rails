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
    !logged_in_user.nil?
  end
  
  # Return the logged in user, if logged in
  def logged_in_user
    unless @logged_in_user
      if session[:user_id]
        @logged_in_user = User.find(session[:user_id]) rescue nil
      else
        @logged_in_user = login_from_cookie
      end
    end
    @logged_in_user
  end
  
  def logged_in_user=(user)
    if !user.nil?
      session[:user_id] = user.id
      @logged_in_user = user
    end
  end
  
  def login_from_cookie
    @logged_in_user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
    if @logged_in_user && @logged_in_user.remember_token?
      handle_remember_cookie!(false) # freshen cookie token (keeping date)
    end
    @logged_in_user
  end

  def valid_remember_cookie?
    return nil unless logged_in_user
    (logged_in_user.remember_token?) && 
      (cookies[:auth_token] == logged_in_user.remember_token)
  end
  
  # Refresh the cookie auth token if it exists, create it otherwise
  def handle_remember_cookie!(new_cookie_flag)
    return unless @logged_in_user
    case
    when valid_remember_cookie? then @logged_in_user.refresh_token # keeping same expiry date
    when new_cookie_flag        then @logged_in_user.remember_me_for(1.year)
    else                             @logged_in_user.forget_me
    end
    send_remember_cookie!
    cookies[:email] = { :value => @logged_in_user.email }
  end

  def kill_remember_cookie!
    cookies.delete :auth_token
  end
  
  def send_remember_cookie!
    cookies[:auth_token] = {
      :value   => logged_in_user.remember_token,
      :expires => logged_in_user.remember_token_expires_at
    }
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