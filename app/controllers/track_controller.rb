class TrackController < ApplicationController
  def index
    @upcoming_events = UpcomingEvents.find_all(:date => Date.today, :weeks => 6, :discipline => "Track")
  end
end