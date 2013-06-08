module Admin
  # Edit teams. All succcessful edit expire cache.
  class TeamsController < Admin::AdminController
    # Params
    # * team_name
    def index
      @name = params['name'] || session['team_name'] || cookies[:team_name] || ''
      if @name.blank?
        @teams = []
      else
        session['team_name'] = @name
        cookies[:team_name] = { :value => @name, :expires => Time.zone.now + 36000 }
        name_like = "%#{@name}%"
        @teams = Team.find_all_by_name_like(@name, RacingAssociation.current.search_results_limit)
        if @teams.size == RacingAssociation.current.search_results_limit
          flash[:warn] = "First #{RacingAssociation.current.search_results_limit} teams"
        end
      end
    
      respond_to do |format|
        format.html
        format.js
        format.json { render :json => @teams.to_json }
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
      params[:team][:updater] = current_person
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

    def update_attribute
      respond_to do |format|
        format.js {
          @team = Team.find(params[:id])
          @team.send "#{params[:name]}=", params[:value]

          @other_teams = @team.teams_with_same_name
          if @other_teams.empty?
            @team.save!
            expire_cache
            render :text => @team.send(params[:name]), :content_type => "text/html"
          else
            render "merge_confirm"
          end
        }
      end
    end
  
    def merge
      @team = Team.find(params[:id])
      @other_team = Team.find(params[:other_team_id])
      @team.merge(@other_team)
      expire_cache
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

    def destroy_name
      name_id = params[:name_id]
      Name.destroy(params[:name_id])
    end
  
    def toggle_member
      team = Team.find(params[:id])
      team.toggle!(:member)
      render :partial => "shared/member", :locals => { :record => team }
    end
    
    protected
    
    def assign_current_admin_tab
      @current_admin_tab = "Team"
    end
  end
end
