# What appear to be duplicate finds are actually existence tests
class ResultsController < ApplicationController
  caches_page :index, :event, :person_event, :team_event, :person, :team
  
  def index
    # TODO Create helper method to return Range of first and last of year
    @year = params['year'].to_i
    @year = Date.today.year if @year == 0
    @discipline = Discipline[params['discipline']]
    @discipline_names = Discipline.find_all_names
    @weekly_series, @events, @competitions = Event.find_all_with_results(@year, @discipline)
  end
  
  def event
    @event = Event.find(params[:event_id])
    
    case @event
    when AgeGradedBar, Bar, TeamBar
      return redirect_to(:controller => 'bar', :action => 'show', :year => @event.year, :discipline => @event.discipline)
    when Cat4WomensRaceSeries
      return redirect_to(cat4_womens_race_series_path(:year => @event.year))
    when OverallBar
      return redirect_to(:controller => 'bar', :action => 'show', :year => @event.year)
    when Ironman
      return redirect_to(ironman_path(:year => @event.year))
    when OregonCup
      return redirect_to(oregon_cup_path(:year => @event.year))
    when RiderRankings
      return redirect_to(rider_rankings_path(:year => @event.year))
    end

    @event = Event.find(
      params[:event_id],
      :include => [ :races => [ :category, { :results => [ :person, { :race => :event }, { :team  => :historical_names } ] } ] ]
    )
    
    render :event
  end
  
  def person_event
    @event = Event.find(params[:event_id])
    @person = Person.find(params[:person_id])
    @results = Result.find(
      :all,
      :include => [ :team, :person, :category, 
                  { :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] },
                  { :scores => [ 
                    { :source_result => [{ :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] }, {:team => :historical_names} ] }, 
                    { :competition_result => { :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] } } ] }
                  ],
      :conditions => ['events.id = ? and people.id = ?', params[:event_id], params[:person_id]]
    )
  end

  def team_event
    @team = Team.find(params[:team_id])
    @event = Event.find(params[:event_id])
    @result = Result.find(
      :first,
      :include => [ :team, :person, :category, 
                  { :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] },
                  { :scores => [ 
                    { :source_result => [{ :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] }, [ :person, { :team => :historical_names }] ] }, 
                    { :competition_result => { :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] } } ] }
                  ],
      :conditions => ['events.id = ? and teams.id = ?', params[:event_id], params[:team_id]]
    )
    raise ActiveRecord::RecordNotFound unless @result
  end
  
  def person
    @person = Person.find(params[:person_id])
    set_date_and_year
    results = Result.find(
      :all,
      :include => [ :team, :person, :category, 
                  { :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] },
                  { :scores => [ 
                    { :source_result => { :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] } }, 
                    { :competition_result => { :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] } } ] }
                  ],
      :conditions => [ "people.id = ? and events.date between ? and ?", @person.id, @date.beginning_of_year, @date.end_of_year ]
    )
    
    @competition_results, @event_results = results.partition do |result|
      result.event.is_a?(Competition)
    end
  end
  
  def team
    @team = Team.find(params[:team_id])
    set_date_and_year
    @results = Result.find(
      :all,
      :include => [ :team, :person, :category, 
                  { :race => [ { :event => [ { :parent => :parent }, :children ] }, :category ] }
                  ],
      :conditions => [ "teams.id = ? and events.date between ? and ?", @team.id, @date.beginning_of_year, @date.end_of_year ]
    )
    @results.reject! do |result|
      result.race.event.is_a?(Competition)
    end
  end
  
  def deprecated_team
    team = Team.find(params[:team_id])
    redirect_to(team_results_path(team), :status => :moved_permanently)
  end
  
  def deprecated_event
    event = Event.find(params[:event_id])
    redirect_to(event_results_path(event), :status => :moved_permanently)
  end
  
  def racer
    person = Person.find(params[:person_id])
    redirect_to person_results_path(person), :status => :moved_permanently
  end
  
  def competition
    event = Event.find(params[:event_id])
    if params[:person_id]
      person = Person.find(params[:person_id])
      redirect_to(event_person_results_path(event, person), :status => :moved_permanently)
    else
      team = Team.find(params[:team_id])
      redirect_to(event_team_results_path(event, team), :status => :moved_permanently)
    end
  end

  def show
    result = Result.find(params[:id])
    if result.person
      redirect_to event_person_results_path(result.event, result.person), :status => :moved_permanently
    elsif result.team
      redirect_to event_team_results_path(result.event, result.team), :status => :moved_permanently
    else
      redirect_to event_results_path(result.event), :status => :moved_permanently
    end
  end
  
  
  private
  
  def set_date_and_year
    if params[:year] && params[:year][/\d\d\d\d/].present?
      @year = params[:year].to_i
    else
      @year = Date.today.year
    end
    @date = Date.new(@year)
  end
end
