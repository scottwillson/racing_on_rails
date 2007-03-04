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

    @events = Event.find(
        :all,
        :include => :standings, 
        :conditions => [%Q{
            events.date between ? and ? 
            and ((parent_id is null and events.id in (select event_id from standings where standings.date between ? and ?))
            or (events.type <> 'WeeklySeries' and events.id in (select parent_id from events where events.date between ? and ? 
              and events.id in (select event_id from standings where standings.date between ? and ?))))
            }, 
            first_of_year, first_of_next_year, first_of_year, first_of_next_year, first_of_year, first_of_next_year, first_of_year, first_of_next_year],
        :order => 'events.date desc'
      )
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
