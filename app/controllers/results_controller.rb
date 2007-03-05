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
    
    @discipline = Discipline[params[:discipline]]
    if @discipline
      discipline_clause = 'events.discipline = ? and '
      conditions = [@discipline.name, first_of_year, first_of_next_year, first_of_year, first_of_next_year]
    else
      discipline_clause = ''
      conditions = [first_of_year, first_of_next_year, first_of_year, first_of_next_year]
    end
    @events = SingleDayEvent.find(
        :all,
        :include => [:standings, :parent], 
        :conditions => [%Q{
            #{discipline_clause}
            events.date between ? and ? 
            and events.id in (select event_id from standings where standings.date between ? and ?)
            and (events.parent_id is null or parents_events.type <> 'MultiDayEvent')
            }] + conditions,
        :order => 'events.date desc'
    )
    @events = @events + MultiDayEvent.find(
        :all,
        :include => [:standings, :events], 
        :conditions => [%Q{
            #{discipline_clause}
            events.date between ? and ?
            and events.type = 'MultiDayEvent'
            and (events.id in (select event_id from standings where standings.date between ? and ?)
                 or events_events.id in (select event_id from standings where standings.date between ? and ?))
            }] + conditions + [first_of_year, first_of_next_year],
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
