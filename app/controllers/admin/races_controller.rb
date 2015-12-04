module Admin
  class RacesController < Admin::AdminController
    before_action :assign_event, only: [ :new, :create, :propagate ]
    before_action :assign_race, only: [ :create, :destroy, :edit, :new, :update, :update_attribute ]
    before_action :require_administrator_or_promoter, only: [ :create, :destroy, :edit, :new, :propagate, :update, :update_attribute ]
    before_action :require_administrator, except: [ :create, :destroy, :edit, :new, :propagate, :update, :update_attribute ]

    def new
      render :edit
    end

    def create
      respond_to do |format|
        format.html do
          if @race.save
            flash[:notice] = "Created #{@race.name}"
            redirect_to edit_admin_race_path(@race)
          else
            render :edit
          end
        end
        format.js do
          @race.category = Category.find_or_create_by(name: "New Category")
          @race.save!
        end
      end
    end

    def edit
      @disciplines = [''] + Discipline.all.collect(&:name)
      @disciplines = @disciplines.sort
    end

    # Update existing Race
    # === Params
    # * id
    # * event: Attributes Hash
    # === Assigns
    # * event: Unsaved Race
    # === Flash
    # * warn
    def update
      if @race.update(race_params)
        expire_cache
        expire_cache
        flash[:notice] = "Updated #{@race.name}"
        return redirect_to(edit_admin_race_path(@race))
      end
      render :edit
    end

    def update_attribute
      respond_to do |format|
        format.js {
          expire_cache
          @race.update! params[:name] => params[:value]
          expire_cache
          render plain: @race.send(params[:name])
        }
      end
    end

    # Permanently destroy race and redirect to Event
    # === Params
    # * id
    # === Flash
    # * notice
    def destroy
      @race = Race.find(params[:id])
      @destroyed = @race.destroy
    end

    # Create Races for all +children+ to match parent Event
    # === Params
    # * event_id: parent Event ID
    def propagate
      @event.propagate_races
    end

    private

    def assign_event
      if params[:event_id].present?
        @event = Event.find params[:event_id]
      elsif params[:race]
        @event = Event.find race_params[:event_id]
      end
    end

    def assign_race
      if params[:id].present?
        @race = Race.find(params[:id])
        @event = @race.event unless @event
      elsif params[:race]
        @race = @event.races.build race_params
      else
        @race = @event.races.build
      end
    end

    def race_params
      params_without_mobile.require(:race).permit(
        :additional_race_only,
        :bar_points,
        :category_id,
        :category_name,
        :city,
        :custom_price,
        :distance,
        :event_id,
        :field_limit,
        :field_size,
        :finishers,
        :full,
        :laps,
        :notes,
        :sanctioned_by,
        :state,
        :time,
        :visible
      )
    end
  end
end
