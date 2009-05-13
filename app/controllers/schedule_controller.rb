# Controller for schedule/calendar in different formats. Default to current year if not provided.
#
# Caches all of its pages
class ScheduleController < ApplicationController
  caches_page :index, :list
  
  # Default calendar format
  # mbrahere default format is list
  # === Params
  # * year: default to current year
  # * discipline
  # === Assigns
  # * year
  # * schedule: instance of year's Schedule::Schedule
  def index
    collect_schedule_data
    render_page
  end

  # List of events -- one line per event
  # === Params
  # * year: default to current year
  # === Assigns
  # * year
  # * schedule: instance of year's Schedule::Schedule
  def list
    collect_schedule_data
    render_page
  end

  def calendar
    collect_schedule_data
    render_page
  end

  private

#  mbrahere added the following method for the sake of dryness
  def collect_schedule_data
      @year = params["year"].to_i
      @year = Date.today.year if @year == 0
      @discipline = Discipline[params["discipline"]]
      @discipline_names = Discipline.find_all_names  #mbrahere added this line
      events = SingleDayEvent.find_all_by_year(@year, @discipline)
      @schedule = Schedule::Schedule.new(@year, events)
  end

end