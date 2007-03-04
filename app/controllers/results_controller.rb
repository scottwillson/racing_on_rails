class ResultsController < ApplicationController
  model :result, :event, :standings, :race, :racer
  session :off
  caches_page :index
  
  def index
    # TODO Create helper method to return Range of first and last of year
  	@year = @params['year'].to_i
  	@year = Date.today.year if @year == 0
  	first_of_year = Date.new(@year, 1, 1)
  	first_of_next_year = Date.new(@year +1, 1, 1)

    # SingleDayEvent with standings and parent is null or not a MultiDayEvent
    # MultiDayEvent, Series, WeeklySeries with standings or events with standings
    # Not a Competition
    @events = SingleDayEvent.find(
        :all,
        :include => [:standings, :parent], 
        :conditions => [%Q{
            (events.date between ? and ? 
            and events.id in (select event_id from standings where standings.date between ? and ?)
            and (events.parent_id is null or parents_events.type <> 'MultiDayEvent'))
            }, 
            first_of_year, first_of_next_year, first_of_year, first_of_next_year],
        :order => 'events.date desc'
      )
      @events = @events + MultiDayEvent.find(
          :all,
          :include => [:standings, :events], 
          :conditions => [%Q{
              events.date between ? and ? 
              and events.type = 'MultiDayEvent'
              and (events.id in (select event_id from standings where standings.date between ? and ?)
                   or events_events.id in (select event_id from standings where standings.date between ? and ?))
              }, 
              first_of_year, first_of_next_year, first_of_year, first_of_next_year, first_of_year, first_of_next_year],
          :order => 'events.date desc'
        )
        @events.sort! {|x, y| y.date <=> x.date}
  end
  
  def event
    @event = Event.find(params[:id])
  end
  
  def racer
  	@racer = Racer.find(params[:id])
  end
  
  def show
  	@result = Result.find(params[:id])
  end
end
