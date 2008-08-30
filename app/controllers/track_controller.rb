class TrackController < ApplicationController
  def index
    @upcoming_events = UpcomingEvents.new(Date.today, 6, "Track")    
  end
end