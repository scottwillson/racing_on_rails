class ResultsSweeper < ActionController::Caching::Sweeper
  observe SingleDayEvent, Standings
  
  def before_save(record)
    expire_page(:controller => "/results")
    expire_page(:controller => "/results", :action => 'index')
    
    for year in Event.find_all_years
      expire_page(:controller => "/results", :action => 'list', :year => year)
      expire_page(:controller => "/results", :year => year)
    end
  end
end