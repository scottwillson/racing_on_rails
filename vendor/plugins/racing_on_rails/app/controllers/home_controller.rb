# Homepage
class HomeController < ApplicationController
  model :discipline
  caches_page :index
  cache_sweeper :home_sweeper

  # Show homepage
  # === Assigns
  # * upcoming_events: instance of UpcomingEvents with default parameters
  def index
    @upcoming_events = UpcomingEvents.new
  end

end
