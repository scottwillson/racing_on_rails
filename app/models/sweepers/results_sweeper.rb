class ResultsSweeper < ActionController::Caching::Sweeper
  
  include FileUtils
  observe SingleDayEvent, MultiDayEvent, Standings
  
  def before_save(record)
    expire_page(:controller => "/results")
    expire_page(:controller => "/results", :action => 'index')
    
    for year in Event.find_all_years
      expire_page(:controller => "/results", :action => 'list', :year => year)
      expire_page(:controller => "/results", :year => year)
    end
    
    rm_rf(File.join(RAILS_ROOT, 'public', 'results'))
    rm_rf(File.join(RAILS_ROOT, 'public', 'rider_rankings'))
    rm_rf(File.join(RAILS_ROOT, 'public', 'rider_rankings.html'))
  end
end