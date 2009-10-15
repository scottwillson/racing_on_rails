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
  
  def show
    @team = Team.find(params[:id])
    @results = Result.find(
      :all,
      :include => [:team, :person, :category, {:race => :event}],
      :conditions => ['teams.id = ?', params[:id]]
    )
    @results.reject! do |result|
      result.race.event.is_a?(Competition)
    end
    render :template => "results/team"
  end
end
