class EventTeamsController < ApplicationController
  force_https

  def index
    @event = Event.includes(:event_teams).find(params[:event_id])
  end

  def show
  end
end
