class Admin::TeamsController < Admin::RecordEditor

  model :team
  edits :team
  
  def index
    @name = @params['name'] || @session['team_name'] || cookies[:team_name] || ''
    if @name.blank?
      @teams = []
    else
      @session['team_name'] = @name
      cookies[:team_name] = {:value => @name, :expires => Time.now + 36000}
      name_like = "%#{@name}%"
      @teams = Team.find(
        :all, 
        :conditions => ['teams.name like ?', name_like], 
        :include => :aliases,
        :limit => RESULTS_LIMIT,
        :order => 'teams.name'
      )
      if @teams.size == RESULTS_LIMIT
        flash[:warn] = "First #{RESULTS_LIMIT} teams"
      end
    end
  end
  
  def create
    begin
      new_name = params[:name]
      @team = Team.new(:name => new_name)
      RACING_ON_RAILS_DEFAULT_LOGGER.debug("Create '#{new_name}'") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
      
      saved = @team.save
      if saved
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("Saved '#{new_name}'") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
        flash[:info] = "Created #{new_name}"
        render(:update) {|page| page.redirect_to(:index)}
      else
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("Could not save '#{new_name}' #{@team.errors.full_messages}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
        render(:partial => 'new')
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{e}\n#{stack_trace}")
      @team.errors.add('name', e)
      render(:partial => 'new')
    end
  end
  
  # Inline
  def edit_name
    @team = Team.find(@params[:id])
    render(:partial => 'edit')
  end
  
  # Inline
  def update
    begin
      new_name = params[:name]
      team_id = @params[:id]
      @team = Team.find(@params[:id])
      original_name = @team.name
      @team.name = new_name
      existing_team = Team.find_by_name_or_alias(new_name)
      if (existing_team and existing_team != @team)
        return merge?(original_name, existing_team, @team)
      end
      if (existing_team and existing_team == @team and existing_team.name.casecmp(@team.name) != 0)
        old_alias = @team.aliases.detect {|a| a.name.casecmp(@team.name) == 0}
        old_alias.name = existing_team.name
        old_alias.save!
      end
      
      saved = @team.save
      if saved
        render(:partial => 'team')
      else
        render(:partial => 'edit')
      end
    rescue Exception => e
      stack_trace = e.backtrace.join("\n")
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{e}\n#{stack_trace}")
      @team.name = original_name
      @team.errors.add('name', e)
      render(:partial => 'edit')
    end
  end
  
  # Inline
  def merge?(original_name, existing_team, team)
    @team = team
    @existing_team = existing_team
    @existing_team_name = team.name
    @original_name = original_name
    render(:partial => 'merge_confirm')
  end
  
  # Inline
  def merge
    team_to_merge_id = @params[:id].gsub('team_', '')
    team_to_merge = Team.find(team_to_merge_id)
    @merged_team_name = team_to_merge.name
    @existing_team = Team.find(@params[:target_id])
    @existing_team.merge(team_to_merge)
  end
  
  # Inline
  def cancel
    if @params[:id]
      @team = Team.find(@params[:id])
      render(:partial => 'team')
    else
      render(:text => '<tr><td colspan=4></td></tr>')
    end
  end
  
  def destroy
    team = Team.find(params[:id])
    begin
      team.destroy
      render :update do |page|
        page.visual_effect(:puff, "team_#{team.id}_row", :duration => 2)
        page.replace_html(
          'message', 
          "#{image_tag('icons/confirmed.gif', :height => 11, :width => 11, :id => 'confirmed') } Deleted #{team.name}"
        )
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      RACING_ON_RAILS_DEFAULT_LOGGER.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{team.name}"
      render :update do |page|
        page.replace_html("message_#{team.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end
end
