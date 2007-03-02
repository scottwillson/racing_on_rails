# Homepage
class HomeController < ApplicationController
  model :discipline
  caches_page :index
        
  # Show homepage
  # === Assigns
  # * upcoming_events: instance of UpcomingEvents with default parameters
  # * recent_results: Events with Results within last two weeks
  def index
    @upcoming_events = UpcomingEvents.new
    
    cutoff = Date.today - 14
    @recent_results = SingleDayEvent.find(
      :all,
      :conditions => ['date > ? and id in (select event_id from standings)', cutoff],
      :order => 'date desc'
    )
  end
end
