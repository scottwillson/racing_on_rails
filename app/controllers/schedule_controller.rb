# Controller for schedule/calendar in different formats. Default to current year if not provided.
#
# Caches all of its pages
class ScheduleController < ApplicationController
  before_filter :assign_schedule
  before_filter :assign_sanctioning_organizations

  caches_page :index, :list, :calendar

  # Default calendar format
  # === Params
  # * year: default to current year
  # * discipline
  # === Assigns
  # * year
  # * schedule: instance of year's Schedule::Schedule
  def index
    @calendar_tab = "Calendar"

    respond_to do |format|
      format.html { render_page }
      format.rss do
        redirect_to schedule_path(format: :atom), status: :moved_permanently
      end
      format.atom
      format.json {
        events = []
        @events.each do |event|
          events << {
            id: event.id,
            title: event.full_name,
            description: event.full_name,
            start: "#{event.date}",
            end: "#{event.end_date}",
            allDay: true,
            url: "#{event.flyer}"
          }
        end
        render json: events.to_json
      }
      format.ics { render_ics }
      format.xls { render_xls }
    end
  end

  # List of events -- one line per event
  # === Params
  # * year: default to current year
  # === Assigns
  # * year
  # * schedule: instance of year's Schedule::Schedule
  def list
    @calendar_tab = "List with race organizer contact information"

    respond_to do |format|
      format.html { render_page }
      format.rss do
        redirect_to schedule_path(format: :atom), status: :moved_permanently
      end
      format.atom
      format.ics { render_ics }
      format.xls { render_xls }
    end
  end

  # MBRA JS-based calendar
  def calendar
    respond_to do |format|
      format.html { render_page }
      format.json do
        events = []
        @events.each do |event|
          events << {
            id: event.id,
            title: event.full_name,
            description: event.full_name,
            start: event.date,
            end: event.end_date,
            allDay: true,
            url: event.flyer
          }
        end
        render json: events.to_json
      end
    end
  end


  private

  def render_ics
    send_data(
      RiCal.Calendar do |cal|
        parent_ids = @events.map(&:parent_id).compact.uniq
        multiday_events = MultiDayEvent.where("id in (?) and type = ?", parent_ids, "MultiDayEvent")
        events = @events.reject { |e| e.postponed? || e.cancelled? || multiday_events.include?(e.parent) } + multiday_events
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
      filename: "#{RacingAssociation.current.name} #{@year} Schedule.ics"
    )
  end

  def render_xls
    send_data(CSV.generate(col_sep: "\t") do |csv|
      csv << [ "id", "parent_id", "date", "name", "discipline", "flyer", "city", "state", "promoter_name" ]
      @events.each do |event|
        csv << [
          event.id,
          event.parent_id,
          event.date.to_s(:db),
          event.full_name,
          event.discipline,
          event.flyer,
          event.city,
          event.state,
          event.promoter_name
        ]
      end
    end, type: :xls)
  end

  def assign_schedule
    @discipline = Discipline[params[:discipline]]
    @discipline_names = Discipline.names

    if RacingAssociation.current.filter_schedule_by_region?
      @regions = Region.all
      @region = Region.where(friendly_param: params[:region]).first
    end

    # year, sanctioning_organization, start, end, discipline, region
    @schedule = Schedule::Schedule.find(
      discipline: @discipline,
      end: end_date,
      region: @region,
      sanctioning_organization: params[:sanctioning_organization],
      start: start_date,
      year: @year
    )
    @events = @schedule.events
  end

  def start_date
    if params[:start].present? && params[:start].to_i > 0 && params[:start][/\A\d+{8,12}\z/]
      Time.zone.at params[:start].to_i
    else
      params[:start]
    end
  end

  def end_date
    if params[:end].present? && params[:end].to_i > 0 && params[:end][/\A\d+{8,12}\z/]
      Time.zone.at params[:end].to_i
    else
      params[:end]
    end
  end

  def assign_sanctioning_organizations
    if RacingAssociation.current.filter_schedule_by_sanctioning_organization?
      @sanctioning_organizations = RacingAssociation.current.sanctioning_organizations
    else
      @sanctioning_organizations = []
    end
  end
end
