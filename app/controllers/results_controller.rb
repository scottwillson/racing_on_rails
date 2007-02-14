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

  	road = [Discipline[:road].name, 
  	        Discipline[:circuit].name, 
  	        Discipline[:criterium].name, 
  	        Discipline[:time_trial].name]
  	mountain_bike = [Discipline[:mountain_bike].name, Discipline[:downhill].name]

  	for discipline in [road, [Discipline[:cyclocross].name], mountain_bike, [Discipline[:track].name]]
      events = SingleDayEvent.find(
        :all,
        :conditions => ['discipline in (?) and date between ? and ? and id in (select event_id from standings)', 
                         discipline, first_of_year, first_of_next_year],
        :order => 'date desc'
      )
      weekly_series_events, events = events.partition {|event|
        event.parent.is_a?(WeeklySeries)
      }
      @events[discipline.first] = events
      
      for event in weekly_series_events
        unless @events[event.parent.name]
          @events[event.parent.name] = []
        end
        @events[event.parent.name] << event
      end
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
