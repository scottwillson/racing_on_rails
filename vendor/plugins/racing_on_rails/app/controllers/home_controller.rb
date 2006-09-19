class HomeController < ApplicationController
  model :discipline
  
  def index
    @upcoming_events = UpcomingEvents.new
  end

end
