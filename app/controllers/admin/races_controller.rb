class Admin::RacesController < Admin::AdminController
  before_filter :assign_event, :only => [ :new, :create, :propagate ]
  before_filter :assign_race, :only => [ :create, :destroy, :edit, :new, :update, :update_attribute ]
  before_filter :require_administrator_or_promoter, :only => [ :create, :destroy, :edit, :new, :propagate, :update, :update_attribute ]
  before_filter :require_administrator, :except => [ :create, :destroy, :edit, :new, :propagate, :update, :update_attribute ]
  layout "admin/application"

  def new
    render :edit
  end
  
  def create
    respond_to do |format|
      format.html {
        if @race.save
          flash[:notice] = "Created #{@race.name}"
          redirect_to edit_admin_race_path(@race)
        else
          render :edit
        end
      }
      format.js {
        @race.category = Category.find_or_create_by_name("New Category")
        @race.save!
      }
    end
  end

  def edit
    @disciplines = [''] + Discipline.all.collect do |discipline|
      discipline.name
    end
    @disciplines.sort!
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
    if @race.update_attributes(params[:race])
      expire_cache
      flash[:notice] = "Updated #{@race.name}"
      return redirect_to(edit_admin_race_path(@race))
    end
    render :edit
  end
  
  def update_attribute
    respond_to do |format|
      format.js {
        @race.send "#{params[:name]}=", params[:value]
        @race.save!
        expire_cache
        render :text => @race.send(params[:name]), :content_type => "text/html"
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
      @event = Event.find params[:race][:event_id]
    end
  end
  
  def assign_race
    if params[:id].present?
      @race = Race.find(params[:id])
      @event = @race.event unless @event
    else
      @race = @event.races.build params[:race]
    end
  end
end
