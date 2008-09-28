class TeamsController < ApplicationController
  def index
    @teams = Team.find(:all, :conditions => { :member => true, :show_on_public_page => true })
  end
  
  def show
    @team = Team.find(params[:id])
    @results = Result.find(
      :all,
      :include => [:team, :racer, :category, {:race => {:standings => :event}}],
      :conditions => ['teams.id = ?', params[:id]]
    )
    @results.reject! do |result|
      result.race.standings.event.is_a?(Competition)
    end
  end
end