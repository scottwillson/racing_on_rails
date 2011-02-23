# Controller for schedule/calendar in different formats. Default to current year if not provided.
#
# Caches all of its pages
class ScheduleController < ApplicationController
  before_filter :assign_schedule_data
  
  caches_page :index, :calendar, :list
  
  # Default calendar format
  # === Params
  # * year: default to current year
  # * discipline
  # === Assigns
  # * year
  # * schedule: instance of year's Schedule::Schedule
  def index
    expires_in 1.hour, :public => true
    render_page
  end

  # List of events -- one line per event
  # === Params
  # * year: default to current year
  # === Assigns
  # * year
  # * schedule: instance of year's Schedule::Schedule
  def list
    expires_in 1.hour, :public => true
    render_page
  end

  def calendar
    expires_in 1.hour, :public => true
    respond_to do |format|
      format.html { render_page }
      format.json {
        events = []
        @events.each do |event|
          events << {:id => event.id, :title => event.full_name, :description => event.full_name, :start => "#{event.date}" , :end => "#{event.end_date}", :allDay => true, :url => "#{event.flyer}"} 
        end
        render :json => events.to_json }
    end
  end

  private

  def assign_schedule_data
    @year = params["year"].to_i
    @year = RacingAssociation.current.effective_year if @year == 0
    start_date = params["start"]
    end_date = params["end"]
    @discipline = Discipline[params["discipline"]]
    @discipline_names = Discipline.find_all_names
    
    if !start_date.blank? and !end_date.blank?
      @events = SingleDayEvent.find_all_by_unix_dates(start_date, end_date, @discipline)
    else
      @events = SingleDayEvent.find_all_by_year(@year, @discipline)
    end
    
    if RacingAssociation.current.include_multiday_events_on_schedule?
      #we will remove the single day events that are children of multi-day events
      if !start_date.blank? and !end_date.blank?
        @events += MultiDayEvent.find_all_by_unix_dates(start_date, end_date, @discipline)
      else
        @events += MultiDayEvent.find_all_by_year(@year, @discipline)
      end
      @events.delete_if {|x| !x.parent_id.nil? } #remove child events
    end

    @schedule = Schedule::Schedule.new(@year, @events)
  end
end
