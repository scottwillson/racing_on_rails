class Admin::TeamsController < Admin::RecordEditor

  edits :team
  
  def index
    @name = params['name'] || session['team_name'] || cookies[:team_name] || ''
    if @name.blank?
      @teams = []
    else
      session['team_name'] = @name
      cookies[:team_name] = {:value => @name, :expires => Time.now + 36000}
      name_like = "%#{@name}%"
      @teams = Team.find(
        :all, 
        :conditions => ['teams.name like ? or aliases.name like ?', name_like, name_like], 
        :include => :aliases,
        :limit => RESULTS_LIMIT,
        :order => 'teams.name'
      )
      if @teams.size == RESULTS_LIMIT
        flash[:warn] = "First #{RESULTS_LIMIT} teams"
      end
    end
  end
  
  def edit
    @team = Team.find(params[:id], :include => [:aliases, :racers])
  end
  
  def new
    @team = Team.new
  end
  
  def create
    begin
      @team = Team.new(params[:team])

      if @team.save
        expire_cache
        flash[:notice] = "Created #{@team.name}"
        redirect_to(edit_admin_team_path(@team))
      else
        render :action => "edit"
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      logger.error("#{e}\n#{stack_trace}")
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
      flash[:warn] = e.to_s
      render :action => "edit"
    end
  end
  
  def update
    begin
      @team = Team.find(params[:id])

      if @team.update_attributes(params[:team])
        expire_cache
        redirect_to(edit_admin_team_path(@team))
      else
        render :action => "new"
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      logger.error("#{e}\n#{stack_trace}")
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
      flash[:warn] = e.to_s
      render :action => "new"
    end
  end
  
  # Inline
  def edit_name
    @team = Team.find(params[:id])
    expire_cache
    render(:partial => 'edit')
  end
  
  # Inline update. Merge with existing Team if names match
  def update_name
    new_name = params[:name]
    team_id = params[:id]
    @team = Team.find(team_id)
    begin
      original_name = @team.name
      @team.name = new_name
      existing_teams = Team.find_all_by_name(new_name) | Alias.find_all_teams_by_name(new_name)
      existing_teams.reject! { |team| team == @team }
      if existing_teams.size > 0
        return merge?(original_name, existing_teams, @team)
      end

      if @team.save
        expire_cache
        render :update do |page| page.replace_html("team_#{@team.id}_name", :partial => 'team_name', :locals => { :team => @team }) end
      else
        render :update do |page|
          page.replace_html("team_#{@team.id}_name", :partial => 'edit', :locals => { :team => @team })
          @team.errors.full_messages.each do |message|
            page.insert_html(:after, "team_#{@team.id}_row", :partial => 'error', :locals => { :error => message })
          end
        end
      end
    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
      render :update do |page|
        if @team
          page.insert_html(:after, "team_#{@team.id}_row", :partial => 'error', :locals => { :error => e })
        else
          page.alert(e.message)
        end
      end
    end
  end
  
  def same_as_other_team?(new_name, team)
    Team.count(:conditions => ['name = ? and id <> ?', new_name, team.id]) > 0
  end
  
  def same_as_other_alias?(new_name)
    Alias.count(:conditions => ['name = ? and team_id is not null', new_name]) > 0
  end
  
  def different?(original_name, new_name)
    original_name.casecmp(new_name) != 0
  end
  
  # Inline
  def merge?(original_name, existing_teams, team)
    @team = team
    @existing_teams = existing_teams
    @original_name = original_name
    render :update do |page| 
      page.replace_html("team_#{@team.id}_name", :partial => 'merge_confirm', :locals => { :team => @team })
    end
  end
  
  # Inline
  def merge
    begin
      team_to_merge_id = params[:id].gsub('team_', '')
      @team_to_merge = Team.find(team_to_merge_id)
      @merged_team_name = @team_to_merge.name
      @existing_team = Team.find(params[:target_id])
      @existing_team.merge(@team_to_merge)
      expire_cache
    rescue Exception => e
      render :update do |page|
        page.visual_effect(:highlight, "team_#{@existing_team.id}_row", :startcolor => "#ff0000", :endcolor => "#FFDE14") if @existing_team
        page.alert("Could not merge teams.\n#{e}")
      end
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
    end
  end
  
  # Cancel inline editing
  def cancel
    @team = Team.find(params[:id])
    render(:partial => 'team_name', :locals => { :team => @team })
  end
  
  def destroy
    @team = Team.find(params[:id])
    begin
      @team.destroy
      respond_to do |format|
        format.html {redirect_to admin_teams_path}
        format.js
      end
      expire_cache
    rescue  Exception => e
      render :update do |page|
        page.visual_effect(:highlight, "team_#{@team.id}_row", :startcolor => "#ff0000", :endcolor => "#FFDE14") if @existing_team
        page.alert("Could not delete #{@team.name}.\n#{e}")
      end
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
    end
  end

  # Exact dupe of racers controller
  def destroy_alias
    alias_id = params[:alias_id]
    Alias.destroy(alias_id)
    render :update do |page|
      page.visual_effect(:puff, "alias_#{alias_id}", :duration => 2)
    end
  end
end
