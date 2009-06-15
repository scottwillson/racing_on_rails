class Admin::RacesController < ApplicationController  
  before_filter :require_administrator
  layout "admin/application"
  cache_sweeper :home_sweeper, :results_sweeper, :schedule_sweeper

  def edit
    @race = Race.find(params[:id])
    @disciplines = [''] + Discipline.find(:all).collect do |discipline|
      discipline.name
    end
    @disciplines.sort!
  end
  
  # Update existing Event
  # === Params
  # * id
  # * event: Attributes Hash
  # === Assigns
  # * event: Unsaved Event
  # === Flash
  # * warn
  def update
    @race = Race.update(params[:id], params[:race])
    if @race.errors.empty?
      expire_cache
      return redirect_to(edit_admin_race_path(@race))
    end
    render(:action => :edit)
  end

  # Permanently destroy race and redirect to Event
  # === Params
  # * id
  # === Flash
  # * notice
  def destroy
    @race = Race.find(params[:id])
    @race.destroy
  end

  # Insert new Result
  # === Params
  # * before_result_id
  # === Flash
  # * notice
  def create_result
    race = Race.find(params[:id])
    @result = race.create_result_before(params[:before_result_id])
    expire_cache
  end

  # Permanently destroy Result
  # === Params
  # * id
  # === Flash
  # * notice
  def destroy_result
    @result = Result.find(params[:result_id])
    @result.race.destroy_result(@result)
    @result.race.results(true)
  end
end