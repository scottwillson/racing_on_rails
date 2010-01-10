class ApplicationController < ActionController::Base
  helper :all
  include ExceptionNotifiable
  include SslRequirement
  
  local_addresses.clear

  # HP"s proxy, among others, gets this wrong
  ActionController::Base.ip_spoofing_check = false

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_person_session, :current_person

  before_filter :toggle_tabs

  def self.expire_cache
    begin
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public", "bar"))
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public", "cat4_womens_race_series"))
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public", "competitions"))
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public", "events"))
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public", "people"))
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public", "rider_rankings"))
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public", "results"))
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public", "schedule"))
      FileUtils.rm_rf(File.join(RAILS_ROOT, "public", "teams"))
      FileUtils.rm(File.join(RAILS_ROOT, "public", "bar.html"), :force => true)
      FileUtils.rm(File.join(RAILS_ROOT, "public", "cat4_womens_race_series.html"), :force => true)
      FileUtils.rm(File.join(RAILS_ROOT, "public", "home.html"), :force => true)
      FileUtils.rm(File.join(RAILS_ROOT, "public", "index.html"), :force => true)
      FileUtils.rm(File.join(RAILS_ROOT, "public", "results.html"), :force => true)
      FileUtils.rm(File.join(RAILS_ROOT, "public", "rider_rankings.html"), :force => true)
      FileUtils.rm(File.join(RAILS_ROOT, "public", "schedule.html"), :force =>true)
      FileUtils.rm(File.join(RAILS_ROOT, "public", "teams.html"), :force =>true)
    rescue Exception => e
      logger.error(e)
    end
    
    true
  end


  protected

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

  private

  def assign_person
    @person = Person.find(params[:id])
  end

  def require_same_person_or_administrator
    unless current_person.administrator? || (@person && current_person == @person)
      redirect_to unauthorized_path
    end
  end
  
  def require_administrator_or_promoter
    unless (current_person && current_person.administrator?) || 
           (@event && current_person == @event.promoter) || 
           (@race && current_person == @race.event.promoter)
           
      redirect_to unauthorized_path
    end
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
      flash[:notice] = "Please login to your #{ASSOCIATION.short_name} account"
      store_location_and_redirect_to_login
      return false
    end
  end

  def require_administrator
    unless current_person && current_person.administrator?
      session[:return_to] = request.request_uri
      flash[:notice] = "You must be an administrator to access this page"
      store_location_and_redirect_to_login
      return false
    end
  end
  
  def store_location_and_redirect_to_login
    if request.format == "js"
      session[:return_to] = request.referrer
      render :update do |page| page.redirect_to(new_person_session_url) end
    else
      session[:return_to] = request.request_uri
      redirect_to new_person_session_url
    end
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end


  # Returns true if the current action is supposed to run as SSL.
  # Intent here is to redirect to non-SSL by default. Individual controllers may override with ssl_required_actions filter.
  def ssl_required?
    ASSOCIATION.ssl? &&
    self.class.read_inheritable_attribute(:ssl_required_actions) &&
    self.class.read_inheritable_attribute(:ssl_required_actions).include?(action_name.to_sym)
  end
  
  # Counter-intuitive. "True" means that we don't care if it's HTTPS or HTTP.
  def ssl_allowed?
    !ASSOCIATION.ssl?
  end
end
