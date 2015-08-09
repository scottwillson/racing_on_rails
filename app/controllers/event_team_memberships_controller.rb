class EventTeamMembershipsController < ApplicationController
  force_https

  def new
    event = Event.find(params[:event_id])
    person = Person.find(params[:person_id])

    if EventTeamMembership.where(event: event, person: person).exists?
      return redirect_to(event_team_membership_path(EventTeamMembership.where(event: event, person: person).first))
    end

    @event_team_membership = event.event_team_memberships.build(person: person, team: Team.new)
    render :edit
  end

  def create
    @event_team_membership = EventTeamMembership.create(event_team_membership_params)
    if @event_team_membership.errors.empty?
      flash[:notice] = "Updated team"
      redirect_to edit_event_team_membership_path(@event_team_membership)
    else
      render :edit
    end
  end

  def edit
    @event_team_membership = EventTeamMembership.find(params[:id])
  end

  def update
    @event_team_membership = EventTeamMembership.find(params[:id])
    if @event_team_membership.update(event_team_membership_params)
      flash[:notice] = "Updated team"
      redirect_to edit_event_team_membership_path(@event_team_membership)
    else
      render :edit
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
      :event_id,
      :person_id,
      :team_id,
      team_attributes: :name
    )
  end
end
