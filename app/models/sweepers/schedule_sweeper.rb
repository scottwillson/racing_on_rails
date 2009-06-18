class ScheduleSweeper < ActionController::Caching::Sweeper
  observe SingleDayEvent
  
  # If event's year changed, we need to expire both schedule pages from both years,
  # so just expire them all
  def after_save(record)
    if Rails.configuration.action_controller.perform_caching    
      expire_page(:controller => "/schedule", :action => 'index')
      expire_page(:controller => "/schedule", :action => 'list')
    
      for year in Event.find_all_years
        expire_page(:controller => "/schedule", :action => 'index', :year => year)
        expire_page(:controller => "/schedule", :action => 'list', :year => year)
      end
    end
  end
end