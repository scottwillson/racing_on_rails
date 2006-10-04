# Homepage
class HomeController < ApplicationController
  model :discipline

  # Show homepage
  # === Assigns
  # * upcoming_events: instance of UpcomingEvents with default parameters
  def index
    @upcoming_events = UpcomingEvents.new
  end

end
