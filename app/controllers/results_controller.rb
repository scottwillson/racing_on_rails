class ResultsController < ApplicationController
  model :result, :event, :standings, :race, :racer
  session :off
  caches_page :index, :event, :competition, :racer, :team, :show
  
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
    @event = Event.find(
      params[:id],
      :include => [:standings => {:races => {:results => {:racer, :team}}}]
    )
    if @event.is_a?(Bar)
      redirect_to(:controller => 'bar', :action => 'show', :year => @event.date.year)
    end
  end

  def competition
  	@competition = Event.find(params[:competition_id])
    if !params[:racer_id].blank?
    	@results = Result.find(
    	  :all,
    	  :include => [:racer, {:race => {:standings => :event}}],
    	  :conditions => ['events.id = ? and racers.id = ?', params[:competition_id], params[:racer_id]]
    	)
    	@racer = Racer.find(params[:racer_id])
  	else
    	@results = Result.find(
    	  :all,
    	  :include => [:team, {:race => {:standings => :event}}],
    	  :conditions => ['events.id = ? and teams.id = ?', params[:competition_id], params[:team_id]]
    	)
    	@team = Team.find(params[:team_id])
    	return render(:template => 'results/team_competition')
	  end
  end
  
  def racer
  	@racer = Racer.find(params[:id])
    results = Result.find(
      :all,
  	  :include => [:team, :racer, :scores, :category, {:race => {:standings => :event}, :race => :category}],
  	  :conditions => ['racers.id = ?', params[:id]]
    )
    @competition_results, @event_results = results.partition do |result|
      result.race.standings.event.is_a?(Competition)
    end
  end
  
  def team
    @team = Team.find(params[:id])
    @results = Result.find(
      :all,
  	  :include => [:team, :racer, :category, {:race => {:standings => :event}}],
  	  :conditions => ['teams.id = ?', params[:id]]
    )
    @results.reject! do |result|
      result.race.standings.event.is_a?(Competition)
    end
  end

  def show
    result = Result.find(params[:id])
    if result.racer
      redirect_to(:action => 'competition', :competition_id => result.event.id, :racer_id => result.racer.id)    
    elsif result.team
      redirect_to(:action => 'competition', :competition_id => result.event.id, :team_id => result.team.id)    
    else
      redirect_to(:action => 'competition', :competition_id => result.event.id)
    end
  end
end
