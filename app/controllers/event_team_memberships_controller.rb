class EventTeamMembershipsController < ApplicationController
  force_https
  before_filter :require_current_person, except: :index

  def new
    event_team = nil
    if params[:slug]
      event = Event.where(slug: params[:slug]).current_year.first!
    else
      event = Event.find(params[:event_id])
    end

    person = nil
    if params[:person_id]
      person = Person.find(params[:person_id])
    else
      person = current_person
    end

    if EventTeamMembership.includes(:event_team).where(event_teams: { event_id: event }).where(person: person).exists?
      return redirect_to(event_team_membership_path(EventTeamMembership.includes(:event_team).where(event_teams: { event_id: event }).where(person: person).first))
    end

    @event_team_membership = event.event_team_memberships.build(person: person, event_team: EventTeam.new(event: event, team: Team.new))
  end

  def create
    @event_team_membership = EventTeamMembership.create(event_team_membership_params)
    if @event_team_membership.errors.empty?
      flash[:notice] = "Joined #{@event_team_membership.team_name}"
      redirect_to event_team_membership_path(@event_team_membership)
    else
      render :new
    end
  end

  def show
    @event_team_membership = EventTeamMembership.find(params[:id])
  end

  def destroy
    @event_team_membership = EventTeamMembership.find(params[:id])
    if @event_team_membership.destroy
      flash[:notice] = "Left #{@event_team_membership.team.name}"
      redirect_to new_event_person_event_team_membership_path(@event_team_membership.event, @event_team_membership.person)
    else
      render :show
    end
  end


  private

  def event_team_membership_params
    params_without_mobile.require(:event_team_membership).permit(
      :event_team_id,
      :person_id,
      event_team_attributes: [ :event_id, { team_attributes: :name } ]
    )
  end
end
