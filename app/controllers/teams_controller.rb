# Public page of all Teams
class TeamsController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        if RacingAssociation.current.show_all_teams_on_public_page?
          @teams = Team.all
        else
          @teams = Team.where(member: true).where(show_on_public_page: true)
        end
        @discipline_names = Discipline.names
      end
      
      format.json do
        @name = params['name']
        if @name.blank?
          @teams = Team.none
        else
          @teams = Team.name_like(@name)
        end

        render json: @teams.limit(100)
      end
    end
  end
end
