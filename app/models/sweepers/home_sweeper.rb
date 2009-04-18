class HomeSweeper < ActionController::Caching::Sweeper
  observe SingleDayEvent, MultiDayEvent, Series, WeeklySeries
  
  def after_save(event)
    if Rails.configuration.action_controller.perform_caching
      expire_page(:controller => "/home", :action => 'index')
      expire_page(:controller => "/home")
    end
  end
end