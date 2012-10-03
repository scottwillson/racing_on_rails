# Controller for schedule/calendar in different formats. Default to current year if not provided.
#
# Caches all of its pages
class ScheduleController < ApplicationController
  before_filter :assign_schedule_data, :except => :show
  before_filter :assign_sanctioning_organizations, :except => :show
  
  caches_page :index, :calendar, :list, :if => Proc.new { |c| !mobile_request? }
  
  # Default calendar format
  # === Params
  # * year: default to current year
  # * discipline
  # === Assigns
  # * year
  # * schedule: instance of year's Schedule::Schedule
  def index
    if mobile_request?
      render :show
    else
      respond_to do |format|
        format.html { render_page }
        format.rss do
          redirect_to schedule_path(:format => :atom), :status => :moved_permanently
        end
        format.atom
        format.ics do
          send_data(
            RiCal.Calendar do |cal|
              parent_ids = @events.map(&:parent_id).compact.uniq
              multiday_events = MultiDayEvent.where("id in (?) and type = ?", parent_ids, "MultiDayEvent")
              events = @events.reject { |e| multiday_events.include?(e.parent) } + multiday_events
              events.each do |e|
                cal.event do |event|
                  event.summary = e.full_name
                  event.dtstart =  e.start_date
                  event.dtend = e.end_date
                  event.location = e.city_state
                  event.description = e.discipline
                  if e.flyer_approved?
                    event.url = e.flyer
                  end
                end
              end
            end,
            :filename => "#{RacingAssociation.current.name} #{@year} Schedule.ics"
          )
        end
        format.xls do
          send_data(CSV.generate(:col_sep => "\t") do |csv|
            csv << [ "id", "parent_id", "date", "name", "discipline", "flyer", "city", "state", "promoter_name" ]
            @events.each do |event|
              csv << [ event.id, event.parent_id, event.date.to_s(:db), event.full_name, event.discipline, event.flyer, event.city, event.state, event.promoter_name ]
            end
          end, :type => :xls)
        end
      end
    end
  end

  # List of events -- one line per event
  # === Params
  # * year: default to current year
  # === Assigns
  # * year
  # * schedule: instance of year's Schedule::Schedule
  def list
    render_page
  end

  def calendar
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
    @discipline_names = Discipline.names
    
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

    if RacingAssociation.current.filter_schedule_by_sanctioning_organization? && params[:sanctioning_organization].present?
      @events = @events.select { |event| event.sanctioned_by == params[:sanctioning_organization] }
    end

    @schedule = Schedule::Schedule.new(@year, @events)
  end
  
  def assign_sanctioning_organizations
    if RacingAssociation.current.filter_schedule_by_sanctioning_organization?
      @sanctioning_organizations = RacingAssociation.current.sanctioning_organizations
    else
      @sanctioning_organizations = []
    end
  end
end
