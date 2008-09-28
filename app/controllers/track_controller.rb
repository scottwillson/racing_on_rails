class TrackController < ApplicationController
  def index
    @upcoming_events = UpcomingEvents.find_all(:date => Date.today, :weeks => 6, :discipline => "Track")
  end
  
  def schedule
    @events = SingleDayEvent.find_all_by_year(Date.today.year, Discipline[:track]) + MultiDayEvent.find_all_by_year(Date.today.year, Discipline[:track])
  end
end