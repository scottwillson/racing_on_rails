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

  	@events = HashWithIndifferentAccess.new
  	for discipline in [Discipline[:road], Discipline[:cyclocross], Discipline[:mountain_bike], Discipline[:track]]
      discipline_events = SingleDayEvent.find(
        :all,
        :conditions => ['discipline = ? and date between ? and ? and id in (select event_id from standings)', 
                         discipline.name, first_of_year, first_of_next_year],
        :order => 'date desc'
      )
      discipline_events.delete_if {|event|
        event.parent.is_a?(WeeklySeries)
      }
      @events[discipline.to_param] = discipline_events
    end
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
