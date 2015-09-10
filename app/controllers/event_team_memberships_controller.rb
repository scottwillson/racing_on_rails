class EventTeamMembershipsController < ApplicationController
  force_https
  before_filter :require_current_person, except: :new

  def new
    if params[:slug].present?
      event = Event.where(slug: params[:slug]).first!
      redirect_to event_event_teams_path(event)
    else
      event = Event.find(params[:event_id])
      redirect_to event_event_teams_path(event)
    end
  end

  def create
    event_team = EventTeam.find(params[:event_team_id])

    EventTeamMembership.transaction do
      if params[:event_team_membership]
        @event_team_membership = event_team.event_team_memberships.build(event_team_membership_params)
      else
        @event_team_membership = event_team.event_team_memberships.build(person: current_person)
      end

      return redirect_to(unauthorized_path) unless person_or_editor?

      EventTeamMembership.includes(:event_team).where(person: @event_team_membership.person, event_teams: { event_id: event_team.event }).destroy_all
      @event_team_membership.save
    end

    if @event_team_membership.errors.empty?
      if @event_team_membership.person == current_person
        flash[:notice] = "You've joined #{@event_team_membership.team_name}"
      else
        flash[:notice] = "Added #{@event_team_membership.person.name} to #{@event_team_membership.team_name}"
      end
    else
      flash[:warn] = "Could not join team: #{@event_team_membership.errors.full_messages.join(', ')}"
    end
    redirect_to event_event_teams_path(@event_team_membership.event)
  end

  def destroy
    @event_team_membership = EventTeamMembership.find(params[:id])

    return redirect_to(unauthorized_path) unless person_or_editor?

    if @event_team_membership.destroy
      flash[:notice] = "Left #{@event_team_membership.team.name}"
    else
      flash[:error] = "Could not leave #{@event_team_membership.team.name}: #{@event_team_membership.errors.full_messages.join(', ')}"
    end
    redirect_to event_event_teams_path(@event_team_membership.event)
  end


  private

  def person_or_editor?
    @event_team_membership.event && @event_team_membership.event.editable_by?(current_person) ||
    @event_team_membership && @event_team_membership.person == current_person
  end

  def event_team_membership_params
    params_without_mobile.
      require(:event_team_membership).permit(
        :person_id,
        { person_attributes: :name }
      )
  end
end
