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
    @road_events = SingleDayEvent.find(
      :all,
      :conditions => ['date between ? and ? and id in (select event_id from standings)', 
                      first_of_year, first_of_next_year],
      :order => 'date desc'
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
