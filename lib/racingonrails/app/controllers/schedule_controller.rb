class ScheduleController < ApplicationController

    session :off

  def index
    @year = params["year"].to_i
    @year = Date.today.year if @year == 0
    events = SingleDayEvent.find(
      :all,
      :conditions => ["date >= ? and date <= ? and sanctioned_by = ?",
                      "#{@year}-01-01", "#{@year}-12-31", ASSOCIATION.short_name])
    @schedule = Schedule.new(@year, events)
  end

  def list
    @year = params["year"].to_i
    @year = Date.today.year if @year == 0
    events = SingleDayEvent.find(
      :all,
      :conditions => ["date >= ? and date <= ? and sanctioned_by = ?",
                      "#{@year}-01-01", "#{@year}-12-31", ASSOCIATION.short_name])
    @schedule = Schedule.new(@year, events)
  end
  
end
