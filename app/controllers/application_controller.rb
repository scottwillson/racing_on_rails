class ApplicationController < ActionController::Base
  helper :all
  include ExceptionNotifiable
  include SentientController
  include SslRequirement
  
  local_addresses.clear

  # HP"s proxy, among others, gets this wrong
  ActionController::Base.ip_spoofing_check = false

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_person_session, :current_person, :secure_redirect_options

  before_filter :clear_racing_association, :toggle_tabs

  def self.expire_cache
    begin
      if Rails.env.production?
        Thread.new {
          system "varnishadm -T 69.30.43.18:2000 'purge.url .*'"
          system "varnishadm -T 69.30.43.19:2000 'purge.url .*'"
        }
      else
        Thread.new {
          system "varnishadm -T 0.0.0.0:2000 'purge.url .*'"
        }
      end
    rescue Exception => e
      logger.error e
    end
    
    true
  end


  protected
  
  def clear_racing_association
    RacingAssociation.current = nil
  end
  
  def toggle_tabs
    @show_tabs = false
  end

  def expire_cache
    if perform_caching
      ApplicationController.expire_cache
    end
  end

  def render_page(path = nil)
    unless path
      path = controller_path
      path = "#{path}/#{action_name}" unless action_name == "index"
    end
    
    page_path = path.dup
    page_path.gsub!(/.html$/, "")
    page_path.gsub!(/index$/, "")
    page_path.gsub!(/\/$/, "")

    @page = Page.find_by_path(page_path)
    if @page
      return render(:inline => @page.body, :layout => true)
    end
  end

  def rescue_action(exception)
    respond_to do |format|
      format.html {
        rescue_with_handler(exception) || rescue_action_without_handler(exception)
      }
      format.js {
        log_error(exception)
        ExceptionNotifier.deliver_exception_notification(exception, self, request, {})
        render "shared/exception", :locals => { :exception => exception }
      }
      format.all {
        rescue_with_handler(exception) || rescue_action_without_handler(exception)
      }
    end
  end

  def render_404
    respond_to do |type|
      type.html {
        local_path = "#{Rails.root}/local/public/404.html"
        if File.exists?(local_path)
          render :file => "#{RAILS_ROOT}/local/public/404.html", :status => "404 Not Found"
        else
          render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found"
        end
      }
      type.all  { render :nothing => true, :status => "404 Not Found" }
    end
  end

  def render_500
    respond_to do |type|
      type.html {
        local_path = "#{Rails.root}/local/public/500.html"
        if File.exists?(local_path)
          render :file => "#{RAILS_ROOT}/local/public/500.html", :status => "500 Error"
        else
          render :file => "#{RAILS_ROOT}/public/500.html", :status => "500 Error"
        end
      }
      type.all  { render :nothing => true, :status => "500 Error" }
    end
  end

  private

  def assign_person
    @person = Person.find(params[:id])
  end

  def current_person_session
    return @current_person_session if defined?(@current_person_session)
    @current_person_session = PersonSession.find
  end

  def current_person
    return @current_person if defined?(@current_person)
    @current_person = current_person_session && current_person_session.person
  end

  def require_person
    unless current_person
      flash[:notice] = "Please login to your #{RacingAssociation.current.short_name} account"
      store_location_and_redirect_to_login
      return false
    end
    true
  end

  def require_administrator
    unless require_person
      return false
    end

    unless current_person.administrator?
      session[:return_to] = request.request_uri
      flash[:notice] = "You must be an administrator to access this page"
      store_location_and_redirect_to_login
      return false
    end
    true
  end

  def require_administrator_or_promoter
    unless require_person
      return false
    end

    unless administrator? || 
           (@event && current_person == @event.promoter) || 
           (@race && current_person == @race.event.promoter)
           
      redirect_to unauthorized_path
      return false
    end
    true
  end

  def require_administrator_or_official
    unless require_person
      return false
    end

    unless administrator? || official?
      session[:return_to] = request.request_uri
      flash[:notice] = "You must be an official or administrator to access this page"
      store_location_and_redirect_to_login
      return false
    end
    true
  end

  def require_same_person_or_administrator
    unless require_person
      return false
    end

    unless administrator? || (@person && current_person == @person)
      redirect_to unauthorized_path
      return false
    end
    true
  end

  def require_same_person_or_administrator_or_editor
    unless require_person
      return false
    end

    unless administrator? || (@person && current_person == @person) || (@person && @person.editors.include?(current_person))
      redirect_to unauthorized_path
      return false
    end
    true
  end

  def require_administrator_or_promoter_or_official
    unless require_person
      return false
    end
    
    unless administrator? || promoter? || official?
      redirect_to unauthorized_path
      return false
    end
    true
  end

  def administrator?
    current_person.try :administrator?
  end

  def official?
    current_person.try :official?
  end

  def promoter?
    current_person.try :promoter?
  end

  def store_location_and_redirect_to_login
    if request.format == "js"
      session[:return_to] = request.referrer
      render :update do |page| page.redirect_to(new_person_session_url(secure_redirect_options)) end
    else
      session[:return_to] = request.request_uri
      redirect_to new_person_session_url(secure_redirect_options)
    end
  end
  
  def secure_redirect_options
    if RacingAssociation.current.ssl?
      { :protocol => "https", :host => request.host }
    else
      {}
    end
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # Returns true if the current action is supposed to run as SSL.
  # Intent here is to redirect to non-SSL by default. Individual controllers may override with ssl_required_actions filter.
  def ssl_required?
    RacingAssociation.current.ssl? &&
    self.class.read_inheritable_attribute(:ssl_required_actions) &&
    self.class.read_inheritable_attribute(:ssl_required_actions).include?(action_name.to_sym)
  end
end
