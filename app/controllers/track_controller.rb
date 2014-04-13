# OBRA Alpenrose track page schedule
class TrackController < ApplicationController
  def index
    @events = Event
                .current_year
                .where(:discipline => "Track")
                .not_child
  end

  def schedule
    return redirect_to(track_path)
  end
end
