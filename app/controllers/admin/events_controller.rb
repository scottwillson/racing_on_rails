# Show Schedule, add and edit Events, show Results for Events
class Admin::EventsController < ApplicationController
  
  model :event, :standings, :combined_standings, :combined_mountain_bike_standings, :combined_time_trial_standings

  # Show results for Event
  # === Params
  # * id: SingleDayEvent id
  # * standings_id: Standings id (optional
  # * race_id: Race id (optional
  # === Assigns
  # * event
  # * standings
  # * race
  # * disciplines: List of all Disciplines + blank
  def show
    @event = Event.find(params[:id])
    if params[:race_id]
      @race = Race.find(params[:race_id])
    elsif params[:standings_id]
      @standings = Standings.find(params[:standings_id])
    end

    @disciplines = [''] + Discipline.find_all.collect do |discipline|
      discipline.name
    end
    @disciplines.sort!
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
    @event = SingleDayEvent.new(:date => date)
  end
  
  # Create new SingleDayEvent
  # === Params
  # * event: Attributes Hash for new event
  # === Assigns
  # * event: Unsaved SingleDayEvent
  # === Flash
  # * warn
  def create
    event_params = params[:event].clone
    if event_params[:promoter].values.all? {|field| field.blank?}
      event_params[:promoter] = nil
    else
      if params[:same_promoter] == 'true'
        promoter = Promoter.find_by_info(event_params[:promoter][:name], event_params[:promoter][:email], event_params[:promoter][:phone])
        promoter = Promoter.create!(event_params[:promoter]) unless promoter
        update_promoter(promoter, event_params[:promoter])
        promoter.save! if promoter
        event_params[:promoter] = promoter
      else
        event_params[:promoter] = Promoter.create!(event_params[:promoter])
      end
    end
    @event = SingleDayEvent.new(event_params)
    if @event.create
      redirect_to(:action => :show, :id => @event.to_param)
    else
      flash[:warn] = @event.errors.full_messages
      "new"
    end
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
    if params[:commit] == 'Delete'
      return destroy_event
    end
    if params[:race_id]
      @race = Race.update(params[:race_id], params[:race])
      if @race.errors.empty?
        redirect_to(:action => :show, :id => params[:id], :standings_id => params[:standings_id], :race_id => params[:race_id])
      else
        render(:action => :show)
      end
    elsif params[:standings_id]
      @standings = Standings.update(params[:standings_id], params[:standings])
      if @standings.errors.empty?
        redirect_to(:action => :show, :standings_id => params[:standings_id], :id => params[:id])
      else
        render(:action => :show)
      end
    else
      begin
        @event = Event.find(params[:id])
        original_event_attributes = @event.attributes.clone if @event.is_a?(MultiDayEvent)
        # TODO consolidate code
        event_params = params[:event].clone
        if event_params[:promoter].values.all? {|field| field.blank?}
          event_params[:promoter] = nil
        elsif params[:same_promoter] == 'true'
          promoter = Promoter.find_by_info(event_params[:promoter][:name], event_params[:promoter][:email], event_params[:promoter][:phone])
          promoter = Promoter.create!(event_params[:promoter]) unless promoter
          update_promoter(promoter, event_params[:promoter])
          promoter.save! if promoter
          event_params[:promoter] = promoter
        else
          event_params[:promoter] = Promoter.create!(event_params[:promoter])
        end
        @event = Event.update(params[:id], event_params)
      rescue Exception => e
        stack_trace = e.backtrace.join("\n")
        logger.error("#{e}\n#{stack_trace}")
        flash[:warn] = e
        return render(:action => :show)
      end
      
      if @event.errors.empty?
        @event.update_events(original_event_attributes) if @event.is_a?(MultiDayEvent)
        redirect_to(:action => :show, :id => params[:id])
      else
        render(:action => :show)
      end
    end
  end

  def upload
    uploaded_file = @params[:results_file]
    path = "#{Dir.tmpdir}/#{uploaded_file.original_filename}"
    File.open(path, File::CREAT|File::WRONLY) do |f|
      f.print(uploaded_file.read)
    end

    temp_file = File.new(path)
    event_id = @params[:id]
    event = Event.find(event_id)
    results_file = ResultsFile.new(temp_file, nil, event)
    begin
      standings = results_file.import(event)
      flash[:notice] = "Uploaded results for #{uploaded_file.original_filename}"
      unless results_file.invalid_columns.empty?
        flash[:warn] = "Invalid columns in uploaded file: #{results_file.invalid_columns.join(', ')}"
      end
      redirect_path = {
        :controller => "/admin/events", 
        :action => :show, 
        :standings_id => standings.to_param,
        :id => event.to_param
      }
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      redirect_path = {
        :controller => "/admin/events", 
        :action => :show, 
        :id => event.to_param,
        
      }
      flash[:warn] = "Could not upload results: #{error}"
    end
    
    redirect_to(redirect_path)
  end
  
  def destroy_event
    event = Event.find(@params[:id])
    begin
      event.destroy
      flash[:notice] = "Deleted #{event.name}"
      redirect_to(
          :controller => "/admin/schedule", 
          :action => "index",
          :year => event.date.year
        )
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{event.name}"
      @event = Event.find(params[:id])
      return render(:action => 'show')
    end
  end
  
  def destroy_standings
    standings = Standings.find(@params[:id])
    begin
      standings.destroy
      flash[:notice] = "Deleted #{standings.name}"
      render :update do |page|
        page.visual_effect(:puff, "standings_#{standings.id}_row", :duration => 2)
        page.redirect_to(
          :controller => "/admin/events", 
          :action => :show, 
          :id => standings.event.to_param
        )
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{standings.name}"
      render :update do |page|
        page.replace_html("message_#{standings.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end
  
  def destroy_race
    race = Race.find(@params[:id])
    begin
      race.destroy
      render :update do |page|
        page.visual_effect(:puff, "race_#{race.id}_row", :duration => 2)
        flash[:notice] = "Deleted #{race.name}"
        page.redirect_to(
          :controller => "/admin/events", 
          :action => :show, 
          :id => race.standings.event.to_param
        )
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{race.name}"
      render :update do |page|
        page.replace_html("message_#{race.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end
  
  def destroy_result
    result = Result.find(@params[:id])
    begin
      result.destroy
      render :update do |page|
        page.visual_effect(:puff, "result_#{result.id}_row", :duration => 2)
        page.replace_html(
          'message', 
          "#{image_tag('icons/confirmed.gif', :height => 11, :width => 11, :id => 'confirmed') } Deleted #{result.place} #{result.name}"
        )
      end
    rescue  Exception => error
      stack_trace = error.backtrace.join("\n")
      logger.error("#{error}\n#{stack_trace}")
      message = "Could not delete #{result.name}"
      render :update do |page|
        page.replace_html("message_#{result.id}", render(:partial => '/admin/error', :locals => {:message => message, :error => error }))
      end
    end
  end
  
  def confirm_if_duplicate_promoter
    render :update do |page|
      page.alert('dupe?')
    end
  end

  def update_bar_points
    bar_points = params[:bar_points]
    race = Race.update(params[:id], :bar_points => bar_points)
    render(:partial => 'bar_points', :locals => {:race => race, :bar_points => bar_points})
  end
  
  def upcoming
    if params['date'].blank?
      @date = Date.today
    else
      @date = Date.new(params['date']['year'].to_i, params['date']['month'].to_i, params['date']['day'].to_i)
    end
    if params['weeks'].blank?
      @weeks = 2
    else
      @weeks = params['weeks']
    end
    @upcoming_events = UpcomingEvents.new(@date, @weeks)
  end
  
  # :nodoc
  def update_promoter(promoter, params)
     if promoter and (params[:name] != promoter.name or params[:email] != promoter.email or params[:phone] != promoter.phone)
       promoter.name = params[:name]
       promoter.email = params[:email]
       promoter.phone = params[:phone]
     end
   end
end
