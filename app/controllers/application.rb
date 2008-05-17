# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all
  include LoginSystem
  include ExceptionNotifiable  
  
  local_addresses.clear
  
  RESULTS_LIMIT = 100
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_racing_on_rails_session_id'
  
  filter_parameter_logging "password"
  
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

