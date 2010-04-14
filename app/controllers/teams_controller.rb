class TeamsController < ApplicationController
  caches_page :index, :show

  def index
    if SHOW_ALL_TEAMS_ON_PUBLIC_PAGE
      @teams = Team.find(:all)
    else
      @teams = Team.find(:all, :conditions => { :member => true, :show_on_public_page => true })
    end
    @discipline_names = Discipline.find_all_names
  end
end
