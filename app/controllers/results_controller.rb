class ResultsController < ApplicationController
  session :off
  caches_page :index, :event, :competition, :racer, :team, :show
  
  def index
    # TODO Create helper method to return Range of first and last of year
  	@year = params['year'].to_i
  	@year = Date.today.year if @year == 0
  	first_of_year = Date.new(@year, 1, 1)
  	last_of_year = Date.new(@year + 1, 1, 1) - 1
  	
  	# Ideally, SQL shouldn't pull out duplicate Events
  	@events = Set.new
  	@discipline = Discipline[params['discipline']]
  	if @discipline
  	  discipline_names = [@discipline.name]
  	  if @discipline == Discipline['road']
  	    discipline_names << 'Circuit'
	    end
      @events = @events + Event.find(
          :all,
          :include => :standings, 
          :conditions => [%Q{
              events.date between ? and ? 
              and events.id in (select event_id from standings where events.date between ? and ?)
              and events.parent_id is null
              and events.type <> 'WeeklySeries'
              and (standings.discipline in (?) or (standings.discipline is null and events.discipline in (?)))
              }, first_of_year, last_of_year, first_of_year, last_of_year, discipline_names, discipline_names],
          :order => 'events.date desc'
      )

      @events = @events + MultiDayEvent.find(
          :all,
          :include => [:standings, :events],
          :conditions => [%Q{
              events.date between ? and ? 
              and events_events.id in (select event_id from standings where discipline in (?) or (discipline is null and events.discipline in (?)))
              and events.type <> 'WeeklySeries'
              }, first_of_year, last_of_year, discipline_names, discipline_names],
          :order => 'events.date desc'
      )

      @weekly_series = WeeklySeries.find(
          :all,
          :include => [:standings, :events],
          :conditions => [%Q{
              events.date between ? and ? 
              and (events.id in (select event_id from standings) 
                   or events_events.id in (select event_id from standings))
              and (standings.discipline in (?) or (standings.discipline is null and events.discipline in (?)))
              }, first_of_year, last_of_year, discipline_names, discipline_names],
          :order => 'events.date desc'
      )

	  else
      @events = @events + Event.find(
          :all,
          :include => :standings,
          :conditions => [%Q{
              events.date between ? and ? 
              and events.id in (select event_id from standings where events.date between ? and ?)
              and events.parent_id is null
              and events.type <> 'WeeklySeries'
              }, first_of_year, last_of_year, first_of_year, last_of_year],
          :order => 'events.date desc'
      )

      @events = @events + MultiDayEvent.find(
          :all,
          :include => [:standings, :events],
          :conditions => [%Q{
              events.date between ? and ? 
              and events_events.id in (select event_id from standings)
              and events.type <> 'WeeklySeries'
              }, first_of_year, last_of_year],
          :order => 'events.date desc'
      )

      @weekly_series = WeeklySeries.find(
          :all,
          :include => [:standings, :events],
          :conditions => [%Q{
              events.date between ? and ? 
              and (events.id in (select event_id from standings) 
                   or events_events.id in (select event_id from standings))
              }, first_of_year, last_of_year],
          :order => 'events.date desc'
      )
	  end
    
    @events = @events.to_a
    @events.reject! {|event| event.is_a?(Competition) || (ASSOCIATION.show_only_association_sanctioned_races_on_calendar && event.sanctioned_by != ASSOCIATION.short_name)}
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
    	  :include => [{:race => {:standings => :event}}, :team],
    	  :conditions => ['events.id = ? and teams.id = ?', params[:competition_id], params[:team_id]]
    	)
    	
    	result_ids = @results.collect {|result| result.id}
    	@scores = Score.find(
    	  :all,
    	  :include => [{:source_result => [:racer, {:race => [:category, {:standings => :event}]}]}],
    	  :conditions => ['competition_result_id in (?)', result_ids]
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
      redirect_to(:action => 'competition', :competition_id => result.event.id, :racer_id => result.racer_id)    
    elsif result.team
      redirect_to(:action => 'competition', :competition_id => result.event.id, :team_id => result.team.id)    
    else
      redirect_to(:action => 'competition', :competition_id => result.event.id)
    end
  end
end
