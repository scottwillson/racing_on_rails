# frozen_string_literal: true

# Public page of all Teams
class TeamsController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        @teams = if RacingAssociation.current.show_all_teams_on_public_page?
                   Team.all
                 else
                   Team.where(member: true).where(show_on_public_page: true)
                 end
        @discipline_names = Discipline.names
      end

      format.json do
        @name = params["name"]
        @teams = if @name.blank?
                   Team.none
                 else
                   Team.name_like(@name)
                 end

        render json: @teams.limit(100)
      end
    end
  end
end
