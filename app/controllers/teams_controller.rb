class TeamsController < ApplicationController
  def index
    @teams = Team.find(:all, :conditions => { :member => true, :show_on_public_page => true })
#mbratodo we display all teams    @teams = Team.find(:all)
    @discipline_names = Discipline.find_all_names  #mbrahere added this line
  end
  
  def show
    @team = Team.find(params[:id])
    @results = Result.find(
      :all,
      :include => [:team, :racer, :category, {:race => :event}],
      :conditions => ['teams.id = ?', params[:id]]
    )
    @results.reject! do |result|
      result.race.event.is_a?(Competition)
    end
  end
end