class TrackController < ApplicationController
  def index
    @upcoming_events = UpcomingEvents.find_all(:weeks => 52, :discipline => "Track")
  end
  
  def schedule
    @events = SingleDayEvent.find_all_by_year(Date.today.year, Discipline[:track], nil) + MultiDayEvent.find_all_by_year(Date.today.year, Discipline[:track])
  end
end