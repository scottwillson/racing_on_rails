# OBRA Alpenrose track page schedule
class TrackController < ApplicationController
  def index
    @upcoming_events = UpcomingEvents.find_all(:weeks => 52, :discipline => "Track")
  end
  
  def schedule
    @events = SingleDayEvent.
                where(
                  "date between ? and ?", 
                  RacingAssociation.current.effective_today.beginning_of_year, 
                  RacingAssociation.current.effective_today.end_of_year
                ).
                where(:discipline => "Track")
  end
end
