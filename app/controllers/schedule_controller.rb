class ScheduleController < ApplicationController

    session :off

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