class ApplicationController < ActionController::Base
  helper :all
  include LoginSystem
  include ExceptionNotifiable  
  
  local_addresses.clear

#  mbratodo: I had removed this line
  RESULTS_LIMIT = 100
  
  # HP's proxy, among others, gets this wrong
  ActionController::Base.ip_spoofing_check = false

  filter_parameter_logging "password"

  def self.expire_cache
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'public', 'results'))
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'public', 'bar'))
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'public', 'schedule'))
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'results.html'), :force => true)
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'schedule.html'), :force =>true)
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'index.html'), :force => true)
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'home.html'), :force => true)
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'bar.html'), :force => true)
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
end
