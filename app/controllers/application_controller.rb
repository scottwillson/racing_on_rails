class ApplicationController < ActionController::Base
  helper :all
  include LoginSystem
  include ExceptionNotifiable  
  
  local_addresses.clear
  
  RESULTS_LIMIT = 100
  
  # HP's proxy, among others, gets this wrong
  ActionController::Base.ip_spoofing_check = false
  
  filter_parameter_logging "password"

  protected
  
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
end
