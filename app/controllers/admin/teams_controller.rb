class Admin::TeamsController < Admin::AdminController
  before_filter :require_administrator
  layout "admin/application"

  in_place_edit_for :team, :name

  def index
    @name = params['name'] || session['team_name'] || cookies[:team_name] || ''
    if @name.blank?
      @teams = []
    else
      session['team_name'] = @name
      cookies[:team_name] = {:value => @name, :expires => Time.now + 36000}
      name_like = "%#{@name}%"
      @teams = Team.find_all_by_name_like(params[:name], SEARCH_RESULTS_LIMIT)
      if @teams.size == SEARCH_RESULTS_LIMIT
        flash[:warn] = "First #{SEARCH_RESULTS_LIMIT} teams"
      end
    end

    respond_to do |wants|
      wants.html
      # TODO Optimize JS call. It shouldn't consider cookie and should pull back only nine results
      wants.js
    end
  end
  
  def edit
    @team = Team.find(params[:id], :include => [:aliases, :people])
  end
  
  def new
    @team = Team.new
    render :edit
  end
  
  def create
    params[:team][:created_by] = current_person
    @team = Team.new(params[:team])

    if @team.save
      expire_cache
      flash[:notice] = "Created #{@team.name}"
      redirect_to(edit_admin_team_path(@team))
    else
      render :action => "edit"
    end
  end
  
  def update
    @team = Team.find(params[:id])

    if @team.update_attributes(params[:team])
      expire_cache
      redirect_to(edit_admin_team_path(@team))
    else
      render :edit
    end
  end
  
  def toggle_member
    team = Team.find(params[:id])
    team.toggle!(:member)
    render(:partial => "shared/member", :locals => { :record => team })
  end
  
  # Inline update. Merge with existing Team if names match
  def set_team_name
    @team = Team.find(params[:id])
    new_name = params[:value]
    original_name = @team.name
    @team.name = new_name

    teams_with_same_name = @team.teams_with_same_name
    unless teams_with_same_name.empty?
      return merge?(original_name, teams_with_same_name, @team)
    end
    
    # Want validation
    @team.name = params[:value]
    if @team.save
      expire_cache
      render :update do |page|
        page.replace_html("team_#{@team.id}_name", @team.name)
      end
    else
      render :update do |page|
        page.alert(@team.errors.full_messages)
        page.replace_html("team_#{@team.id}_name", original_name)
      end
    end
  end
  
  # Inline
  def merge?(original_name, existing_teams, team)
    @team = team
    @existing_teams = existing_teams
    @original_name = original_name
    render :update do |page| 
      page.replace_html("team_#{@team.id}_row", :partial => 'merge_confirm', :locals => { :team => @team })
    end
  end
  
  # Inline
  def merge
    team_to_merge_id = params[:id].gsub('team_', '')
    @team_to_merge = Team.find(team_to_merge_id)
    @merged_team_name = @team_to_merge.name
    @existing_team = Team.find(params[:target_id])
    @existing_team.merge(@team_to_merge)
    expire_cache
  end
  
  # Cancel inline editing
  def cancel_in_place_edit
    team_id = params[:id]
    render :update do |page|
      page.replace("team_#{team_id}_row", :partial => "team", :locals => { :team => Team.find(team_id) })
      page.call :restripeTable, :teams_table
    end
  end
  
  def destroy
    @team = Team.find(params[:id])
    if @team.destroy
      expire_cache
      redirect_to admin_teams_path
    else
      render :edit
    end
  end
  
  # Exact dupe of people controller
  def destroy_alias
    alias_id = params[:alias_id]
    Alias.destroy(alias_id)
    render :update do |page|
      page.visual_effect(:puff, "alias_#{alias_id}", :duration => 2)
    end
  end

  def destroy_historical_name
    historical_name_id = params[:historical_name_id]
    HistoricalName.destroy(params[:historical_name_id])
    render :update do |page|
      page.visual_effect(:puff, "historical_name_#{historical_name_id}", :duration => 2)
    end
  end
end
