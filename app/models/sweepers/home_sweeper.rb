class HomeSweeper < ActionController::Caching::Sweeper
  observe SingleDayEvent, MultiDayEvent, Series, WeeklySeries
  
  def after_save(event)
    expire_page(:controller => "/home", :action => 'index')
    expire_page(:controller => "/home")
  end
end