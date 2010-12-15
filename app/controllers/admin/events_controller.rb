# Show Schedule, add and edit Events, edit Results for Events. Promoters can view and edit their own events. Promoters can edit
# fewer fields than administrators.
class Admin::EventsController < Admin::AdminController
  before_filter :assign_event, :only => [ :edit, :update ]
  before_filter :require_administrator_or_promoter, :only => [ :edit, :update ]
  before_filter :require_administrator, :except => [ :edit, :update ]
  before_filter :assign_disciplines, :only => [ :new, :create, :edit, :update ]
  layout 'admin/application'
  in_place_edit_for :event, :first_aid_provider
  in_place_edit_for :event, :chief_referee
  
  # schedule calendar  with links to admin Event pages
  # === Params
  # * year: (optional) defaults to current year
  # === Assigns
  # * schedule
  # * year
  def index
    @year = params["year"].to_i
    @year = RacingAssociation.current.effective_year if @year == 0
    @competitions = Event.find.all(
                        :conditions => ["type in (?) and date between ? and ?", Competition::TYPES, "#{@year}-01-01", "#{@year}-12-31"]
                      )
    events = SingleDayEvent.find.all( :conditions => ["date between ? and ?", "#{@year}-01-01", "#{@year}-12-31"])
    @schedule = Schedule::Schedule.new(@year, events)
  end

  # Show results for Event
  # === Params
  # * id: SingleDayEvent id
  # === Assigns
  # * event
  # * disciplines: List of all Disciplines + blank
  def edit
    if params['promoter_id'].present? && current_person.administrator?
      @event.promoter = Person.find(params['promoter_id'])
    end
  end
  
  # Show page to create new Event
  # === Params
  # * year: optional
  # === Assigns
  # * event: Unsaved SingleDayEvent
  def new
    if params[:year].blank?
      date = RacingAssociation.current.effective_year
    else
      year = params[:year]
      date = Date.new(year.to_i)
    end
    assign_new_event
    association_number_issuer = NumberIssuer.find_by_name(RacingAssociation.current.short_name)
    if association_number_issuer
      @event.number_issuer_id = association_number_issuer.id
    end
    
    respond_to do |format|
      format.html { render :action => :edit }
      format.js { render(:update) { |page| page.redirect_to(:action => :new, :event => params[:event]) } }
    end
  end
  
  # Create new SingleDayEvent
  # === Params
  # * event: Attributes Hash for new event
  # === Assigns
  # * event: Unsaved SingleDayEvent
  # === Flash
  # * warn
  def create
    assign_new_event
    if @event.save
      expire_cache
      flash[:notice] = "Created #{@event.name}"
      redirect_to edit_admin_event_path(@event)
    else
      flash[:warn] = @event.errors.full_messages
      render :edit
    end
  end
  
  # Create new MultiDayEvent from 'prototype' SingleDayEvent
  # === Params
  # * id: SingleDayEvent
  # === Flash
  # * warn
  def create_from_children
    single_day_event = Event.find(params[:id])
    new_parent = MultiDayEvent.create_from_children(single_day_event.multi_day_event_children_with_no_parent)
    expire_cache
    redirect_to(:action => :edit, :id => new_parent.to_param)
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
    # TODO consolidate code
    event_params = params[:event].clone
    event_type = event_params.delete(:type)
    
    @event = Event.update(params[:id], event_params)
    
    if event_type == ""
      event_type = "Event"
    end
    if !event_type.blank? && event_type != @event.type
      raise "Unknown event type: #{event_type}" unless ['Event', 'SingleDayEvent', 'MultiDayEvent', 'Series', 'WeeklySeries'].include?(event_type)
      if event_type == 'SingleDayEvent' && @event.is_a?(MultiDayEvent)
        @event.children.each do |child|
          child.parent = nil
          child.save!
        end
      end
      if @event.save
        Event.connection.execute("update events set type = '#{event_type}' where id = #{@event.id}")
        @event = Event.find(@event.id)
      end
    end
    
    if @event.errors.empty?
      expire_cache
      flash[:notice] = "Updated #{@event.name}"
      redirect_to(edit_admin_event_path(@event))
    else
      render(:action => :edit)
    end
  end

  # Upload results from Excel spreadsheet. 
  # Expects column headers in first row
  # Expects Race names in first column before set of results:
  # Senior Women Category 3
  # | 1 | Leitheiser | Ann | HFV |
  # === Params
  # * results_file
  # * id: Event ID
  # === Flash
  # * warn: List invalid columns
  # * notice
  def upload
    uploaded_file = params[:results_file]
    
    path = "#{Dir.tmpdir}/#{uploaded_file.original_filename}"
    File.open(path, "wb") do |f|
      f.print(uploaded_file.read)
    end

    temp_file = File.new(path)
    event = Event.find(params[:id])
    
    if File.extname(path) == ".lif"
      results_file = Results::LifFile.new(temp_file, event)
    else
      results_file = Results::ResultsFile.new(temp_file, event)
    end
    
    results_file.import
    expire_cache
    FileUtils.rm temp_file rescue nil
    
    flash[:notice] = "Imported #{uploaded_file.original_filename}. "
    unless results_file.custom_columns.empty?
      flash[:notice] = flash[:notice] + "Found custom columns: #{results_file.custom_columns.map(&:humanize).join(", ")}. "
      flash[:notice] = flash[:notice] + "(If import file is USAC format, you should expect errors on Organization, Event Year, Event #, Race Date and Discipline.)" if RacingAssociation.current.usac_results_format?
    end
    
    redirect_to(edit_admin_event_path(event))
  end
  
  # Upload new Excel Schedule
  # See Schedule::Schedule.import for details
  # Redirects to schedule index if succesful
  # === Params
  # * schedule_file
  # === Flash
  # * notice
  # * warn
  def upload_schedule
    uploaded_file = params[:schedule_file]
    path = "#{Dir.tmpdir}/#{uploaded_file.original_filename}"
    File.open(path, "wb") do |f|
      f.print(uploaded_file.read)
    end

    date = Schedule::Schedule.import(path)
    expire_cache
    flash[:notice] = "Uploaded schedule from #{uploaded_file.original_filename}"
    
    redirect_to(admin_events_path)
  end
  
  # Permanently destroy Event
  # === Params
  # * id
  # === Assigns
  # * event: if Event could not be deleted
  # === Flash
  # * notice
  def destroy
    @event = Event.find(params[:id])
    if @event.destroy
      expire_cache
      respond_to do |format|
        format.html {
          flash[:notice] = "Deleted #{@event.name}"
          if @event.parent
            redirect_to(edit_admin_event_path(@event.parent))
          else
            redirect_to(admin_events_path(:year => @event.date.year))
          end
        }
        format.js
      end
    else
      respond_to do |format|
        format.html {
          flash[:notice] = "Could not delete #{@event.name}: #{@event.errors.full_messages}"
          redirect_to(admin_events_path(:year => @event.date.year))
        }
        format.js { render "destroy_error" }
      end
    end
  end
  
  def destroy_races
    @event = Event.find(params[:id])
    # Remember races for view
    @races = @event.races.dup
    @combined_results = @event.combined_results
    @event.destroy_races
    expire_cache
  end

  def set_parent
    child = Event.find(params[:child_id])
    parent = Event.find(params[:parent_id])
    child.parent = parent
    child.save!
    redirect_to(edit_admin_event_path(child))
  end

  # Add missing child Events to this Event (their parent)
  def add_children
    parent = Event.find(params[:parent_id])
    parent.missing_children.each do |child|
      child.parent = parent
      child.save!
    end
    redirect_to(edit_admin_event_path(parent))
  end
  
  protected
  
  def assign_disciplines
    @disciplines = Discipline.find_all_names
  end
  
  def assign_event
    @event = Event.find(params[:id])
  end
  
  def assign_new_event
    if params[:event] && params[:event][:type].present?
      event_type = params[:event][:type]
    elsif params[:event] && params[:event][:parent_id].present?
      event_type = "Event"
    else
      event_type = "SingleDayEvent"
    end
    raise "Unknown event type: #{event_type}" unless ['Event', 'SingleDayEvent', 'MultiDayEvent', 'Series', 'WeeklySeries'].include?(event_type)
    @event = eval(event_type).new(params[:event])
  end
end
