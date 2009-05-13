class ResultsController < ApplicationController
  caches_page :index, :event, :competition, :racer, :team, :show
  
  def index
    # TODO Create helper method to return Range of first and last of year
    @year = params['year'].to_i
    @year = Date.today.year if @year == 0
    first_of_year = Date.new(@year, 1, 1)
    last_of_year = Date.new(@year + 1, 1, 1) - 1
    
    @discipline = Discipline[params['discipline']]
    if @discipline
#mbratodo removed below
      discipline_names = [@discipline.name]
      if @discipline == Discipline['road']
        discipline_names << 'Circuit'
      end
#mbratodo removed above
      @events = Set.new(Event.find(
          :all,
          :conditions => [%Q{
              events.date between ? and ? 
              and events.parent_id is null
              and events.type <> 'WeeklySeries'
              and events.discipline in (?)
              }, first_of_year, last_of_year, discipline_names],
#mbratodo I had:
#              and events.discipline = (?)
#              }, first_of_year, last_of_year, @discipline.name],
          :order => 'events.date desc'
      ))
      
    else
      @events = Set.new(Event.find(
          :all,
          :select => "distinct events.id, events.*",
          :joins => { :races => :results },
          :conditions => ["events.date between ? and ?", first_of_year, last_of_year]
      ))
      
      @events.map!(&:root)
    end
    
    @weekly_series, @events = @events.partition { |event| event.is_a?(WeeklySeries) }
    
    @events.reject! do |event|
      (!event.is_a?(SingleDayEvent) && !event.is_a?(MultiDayEvent)) ||
      (ASSOCIATION.show_only_association_sanctioned_races_on_calendar && event.sanctioned_by != ASSOCIATION.short_name)
    end

#mbrahere added the following
    @discipline_names = Discipline.find_all_names
  end
  
  def event
    @event = Event.find(
      params[:id],
      :include => [:races => {:results => {:racer, :team}} ]
    )
    if @event.is_a?(Bar)
      redirect_to(:controller => 'bar', :action => 'show', :year => @event.year)
    elsif @event.is_a? Ironman
      redirect_to ironman_path(:year => @event.year)
    end
  end

  def competition
    @competition = Event.find(params[:competition_id])
    if !params[:racer_id].blank?
      @results = Result.find(
        :all,
        :include => [:racer, {:race => :event }],
        :conditions => ['events.id = ? and racers.id = ?', params[:competition_id], params[:racer_id]]
      )
      @racer = Racer.find(params[:racer_id])
    else
      @results = Result.find(
        :all,
        :include => [{:race => :event }, :team],
        :conditions => ['events.id = ? and teams.id = ?', params[:competition_id], params[:team_id]]
      )
      
      result_ids = @results.collect {|result| result.id}
      @scores = Score.find(
        :all,
        :include => [{:source_result => [:racer, {:race => [:category, :event ]}]}],
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
      :include => [:team, :racer, :scores, :category, { :race => :event, :race => :category }],
      :conditions => ['racers.id = ?', params[:id]]
    )
    @competition_results, @event_results = results.partition do |result|
      result.event.is_a?(Competition)
    end
  end
  
  def team
    @team = Team.find(params[:id])
    redirect_to(team_path(@team), :status => :moved_permanently)
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
