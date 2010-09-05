# Public page of all Teams
class TeamsController < ApplicationController
  caches_page :index, :show

  def index
    if RacingAssociation.current.show_all_teams_on_public_page?
      @teams = Team.find(:all)
    else
      @teams = Team.find(:all, :conditions => { :member => true, :show_on_public_page => true })
    end
    @discipline_names = Discipline.find_all_names
  end
end
