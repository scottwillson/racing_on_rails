module Admin
  # Edit teams. All succcessful edit expire cache.
  class TeamsController < Admin::AdminController
    # Params
    # * team_name
    def index
      @name = params['name'] || session['team_name'] || cookies[:team_name] || ''
      if @name.blank?
        @teams = Team.none
      else
        session['team_name'] = @name
        cookies[:team_name] = { value: @name, expires: Time.zone.now + 36000 }
        @teams = Team.name_like(@name)
      end

      respond_to do |format|
        format.html { @teams = @teams.page(page) }
        format.js   { @teams = @teams.limit(100) }
        format.json { render json: @teams.limit(100).to_json }
      end
    end

    def edit
      @team = Team.includes(:aliases, :people).find(params[:id])
    end

    def new
      @team = Team.new
      render :edit
    end

    def create
      team_params[:updated_by] = current_person
      @team = Team.new(team_params)

      if @team.save
        expire_cache
        flash[:notice] = "Created #{@team.name}"
        redirect_to(edit_admin_team_path(@team))
      else
        render :edit
      end
    end

    def update
      @team = Team.find(params[:id])

      if @team.update(team_params)
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
          @team[params[:name]] = params[:value]

          @other_teams = @team.teams_with_same_name
          if @other_teams.empty?
            @team.save!
            expire_cache
            render plain: @team[params[:name]]
          else
            render "merge_confirm"
          end
        }
      end
    end

    def merge
      @team = Team.find(params[:id])
      @other_team = Team.find(params[:other_team_id])
      @merged = @team.merge(@other_team)
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
      Name.destroy(params[:name_id])
      expire_cache
    end

    def toggle_member
      team = Team.find(params[:id])
      team.toggle!(:member)
      expire_cache
      render partial: "shared/member", locals: { record: team }
    end

    protected

    def assign_current_admin_tab
      @current_admin_tab = "Team"
    end


    private

    def team_params
      params_without_mobile.require(:team).permit(
        :contact_email,
        :contact_name,
        :contact_phone,
        :member,
        :name,
        :show_on_public_page,
        :sponsors,
        :website
      )
    end
  end
end
