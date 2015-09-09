class EventTeamsController < ApplicationController
  force_https

  before_action :require_current_person, only: :create

  def index
    @event = Event.includes(:event_teams).find(params[:event_id])
    @event_team = EventTeam.new(event: @event, team: Team.new)

    if @event.event_teams?
      render :index
    else
      render :no_event_teams
    end
  end

  def create
    event = Event.find(params[:event_id])
    event_team = event.event_teams.build(event_team_params)
    if event_team.save
      if !event.editable_by?(current_person) && current_person.event_team_memberships.none? { |m| m.event == event }
        event_team.event_team_memberships.create(event_team: event_team, person: current_person)
      end
      flash[:notice] = "Added #{event_team.name} for #{event.name}"
    else
      flash[:warn] = "Could not add team: #{event_team.errors.full_messages.join(', ')}"
    end
    redirect_to event_event_teams_path(event)
  end

  private

  def event_team_params
    params_without_mobile.require(:event_team).permit(
      :event_id,
      team_attributes: [ :name ]
    )
  end
end
