class ResultsController < ApplicationController
  caches_page :index, :show
  
  def index
    if params[:event_id].present?
      if params[:person_id].present?
        return person_event
      elsif params[:team_id].present?
        return team_event
      else
        return event
      end
    else
      if params[:person_id].present?
        return person
      elsif params[:team_id].present?
        return team
      end      
    end

    # TODO Create helper method to return Range of first and last of year
    @year = params['year'].to_i
    @year = Date.today.year if @year == 0
    @discipline = Discipline[params['discipline']]
    @discipline_names = Discipline.find_all_names
    @weekly_series, @events, @competitions = Event.find_all_with_results(@year, @discipline)
  end
  
  def event
    @event = Event.find(
      params[:event_id],
      :include => [ :races => { :results => { :person, :team } } ]
    )
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

    render "event"
  end
  
  def person_event
    @event = Event.find(
      params[:event_id],
      :include => [:races => {:results => {:person, :team}} ]
    )
    @results = Result.find(
      :all,
      :include => [:person, {:race => :event }],
      :conditions => ['events.id = ? and people.id = ?', params[:event_id], params[:person_id]]
    )
    @person = Person.find(params[:person_id])
    render "person_event"
  end

  def team_event
    @event = Event.find(
      params[:event_id],
      :include => [:races => {:results => {:person, :team}} ]
    )
    @results = Result.find(
      :all,
      :include => [{:race => :event }, :team],
      :conditions => ['events.id = ? and teams.id = ?', params[:event_id], params[:team_id]]
    )
    
    result_ids = @results.collect {|result| result.id}
    @scores = Score.find(
      :all,
      :include => [{:source_result => [:person, {:race => [:category, :event ]}]}],
      :conditions => ['competition_result_id in (?)', result_ids]
    )
    @team = Team.find(params[:team_id])
    render "team_event"
  end
  
  def person
    @person = Person.find(params[:person_id])
    results = Result.find(
      :all,
      :include => [:team, :person, :scores, :category, { :race => :event, :race => :category }],
      :conditions => ['people.id = ?', @person.id]
    )
    @competition_results, @event_results = results.partition do |result|
      result.event.is_a?(Competition)
    end
    render "person"
  end
  
  def team
    @team = Team.find(params[:team_id])
    @results = Result.find(
      :all,
      :include => [:team, :person, :category, {:race => :event}],
      :conditions => ['teams.id = ?', params[:team_id]]
    )
    @results.reject! do |result|
      result.race.event.is_a?(Competition)
    end
    render "team"
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
end
