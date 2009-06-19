# Show Schedule, add and edit Events, edit Results for Events
class Admin::EventsController < ApplicationController  
  before_filter :require_administrator
  layout 'admin/application'
  in_place_edit_for :event, :first_aid_provider
  cache_sweeper :home_sweeper, :results_sweeper, :schedule_sweeper, :only => [:create, :update, :destroy_event, :upload]
  
  # schedule calendar  with links to admin Event pages
  # === Params
  # * year: (optional) defaults to current year
  # === Assigns
  # * schedule
  # * year
  def index
    @year = params["year"].to_i
    @year = Date.today.year if @year == 0
    events = SingleDayEvent.find(:all, :conditions => ["date between ? and ?", "#{@year}-01-01", "#{@year}-12-31"])
    @schedule = Schedule::Schedule.new(@year, events)
  end

  # Show results for Event
  # === Params
  # * id: SingleDayEvent id
  # === Assigns
  # * event
  # * disciplines: List of all Disciplines + blank
  def edit
    @event = Event.find(params[:id])
    @disciplines = [''] + Discipline.find(:all).collect do |discipline|
      discipline.name
    end
    @disciplines.sort!
    
    unless params['promoter_id'].blank?
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
      date = Date.today
    else
      year = params[:year]
      date = Date.new(year.to_i)
    end
    if params[:event] && params[:event][:type] == "Event"
      @event = Event.new(params[:event])
    else
      @event = SingleDayEvent.new(params[:event])
    end
    association_number_issuer = NumberIssuer.find_by_name(ASSOCIATION.short_name)
    @event.number_issuer_id = association_number_issuer.id
    
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
    event_type = params[:event][:type]
    event_type = "Event" if event_type.blank?
    raise "Unknown event type: #{event_type}" unless ['Event', 'SingleDayEvent', 'MultiDayEvent', 'Series', 'WeeklySeries'].include?(event_type)
    if params[:event][:parent_id].present?
      @event = Event.find(params[:event][:parent_id]).children.build(params[:event])
    else
      @event = eval(event_type).new(params[:event])
    end
    if @event.save
      expire_cache
      flash[:notice] = "Created #{@event.name}"
      redirect_to(:action => :new, :event => params[:event])
    else
      flash[:warn] = @event.errors.full_messages
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
    expire_cache
    @event = Event.find(params[:id])
    # TODO consolidate code
    event_params = params[:event].clone
    event_type = event_params.delete(:type)
    @event = Event.update(params[:id], event_params)
    if !event_type.blank? && event_type != @event.type
      raise "Unknown event type: #{event_type}" unless ['SingleDayEvent', 'MultiDayEvent', 'Series', 'WeeklySeries'].include?(event_type)
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
    results_file = ResultsFile.new(temp_file, event)
    results_file.import
    expire_cache
    flash[:notice] = "Uploaded results for #{uploaded_file.original_filename}"
    unless results_file.invalid_columns.empty?
      flash[:warn] = "Invalid columns in uploaded file: #{results_file.invalid_columns.join(', ')}"
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
  
  # :nodoc  
  def add_children
    parent = Event.find(params[:parent_id])
    parent.missing_children.each do |child|
      child.parent = parent
      child.save!
    end
    redirect_to(edit_admin_event_path(parent))
  end
end
