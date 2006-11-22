class ScheduleSweeper < ActionController::Caching::Sweeper
  observe SingleDayEvent, Promoter
  
  # If event's year changed, we need to expire both schedule pages from both years,
  # so just expire them all
  def before_save(record)
    expire_page(:controller => "/schedule", :action => 'index')
    expire_page(:controller => "/schedule", :action => 'list')
    
    for year in Event.find_all_years
      expire_page(:controller => "/schedule", :action => 'index', :year => year)
      expire_page(:controller => "/schedule", :action => 'list', :year => year)
    end
  end
end