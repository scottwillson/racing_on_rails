class Admin::StandingsController < ApplicationController
  before_filter :check_administrator_role
  layout "admin/application"
  cache_sweeper :home_sweeper, :results_sweeper, :schedule_sweeper

  def edit
    @standings = Standings.find(params[:id])

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
    @standings = Standings.update(params[:id], params[:standings])
    if @standings.errors.empty?
      expire_cache
      return redirect_to(edit_admin_standings_path(@standings))
    end
    render(:action => :edit)
  end

  # Permanently destroy Standings and redirect to Event
  # === Params
  # * id
  # === Flash
  # * notice
  def destroy
    standings = Standings.find(params[:id])
    standings.destroy
    expire_cache
    flash[:notice] = "Deleted #{standings.name}"
    render :update do |page|
      page.visual_effect(:puff, "standings_#{standings.id}_row", :duration => 2)
      page.redirect_to(
        :controller => "/admin/events", 
        :action => :edit, 
        :id => standings.event.to_param
      )
    end
  end
end