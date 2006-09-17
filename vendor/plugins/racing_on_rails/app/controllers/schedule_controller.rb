class ScheduleController < ApplicationController

    session :off
    model :event, :single_day_event

    def index
      @year = params["year"].to_i
      @year = Date.today.year if @year == 0
      events = SingleDayEvent.find_all_by_year(@year)
      @schedule = Schedule::Schedule.new(@year, events)
    end

    def list
      @year = params["year"].to_i
      @year = Date.today.year if @year == 0
      events = SingleDayEvent.find_all_by_year(@year)
      @schedule = Schedule::Schedule.new(@year, events)
    end
  
end