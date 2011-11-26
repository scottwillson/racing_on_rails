# What appear to be duplicate finds are actually existence tests.
# Many methods to handle old URLs that search engines still hit. Will be removed.
class ResultsController < ApplicationController
  include Api::Results

  caches_page :index, :event, :person, :person_event, :team
  
  # HTML: Formatted links to Events with Results
  # == Params
  # * year (optional)
  # JSON, XML: Remote API
  # == Returns
  # JSON and XML results are paginated with a page size of 10
  # * results: [ :id, :age, :city, :date_of_birth, :license, :number, :place,
  # :place_in_category, :points, :points_from_place,
  # :points_bonus_penalty, :points_total, :state, :time,
  # :time_gap_to_leader, :time_gap_to_previous, :time_gap_to_winner,
  # :laps, :points_bonus, :points_penalty, :preliminary, :gender,
  # :category_class, :age_group, :custom_attributes ]
  #
  # * person: [ :id, :first_name, :last_name, :license ]
  # * category: [ :id, :name, :ages_begin, :ages_end, :friendly_param ]
  #
  # See source code of Api::Results and Api::Base
  def index
    expires_in 1.hour, :public => true
    respond_to do |format|
      format.html {
        @year = params['year'].to_i
        @year = Date.today.year if @year == 0
        @discipline = Discipline[params['discipline']]
        @discipline_names = Discipline.names
        @weekly_series, @events, @competitions = Event.find_all_with_results(@year, @discipline)
      }
      format.xml { render :xml => results_as_xml }
      format.json { render :json => results_as_json }
    end
  end
  
  # All Results for Event
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

    ResultsController::benchmark "Load results", :level => :debug do
      @event = Event.find(
        params[:event_id],
        :include => [ :races => [ :category, { :results => :team } ] ]
      )
    end
    
    expires_in 1.hour, :public => true
  end
  
  # Single Person's Results for a single Event
  def person_event
    @event = Event.find(params[:event_id])
    @person = Person.find(params[:person_id])
    @results = Result.all(
      :include => { :scores => [ :source_result, :competition_result ] },
      :conditions => ['results.event_id = ? and person_id = ?', params[:event_id], params[:person_id]]
    )
    expires_in 1.hour, :public => true
  end

  # Single Team's Results for a single Event
  def team_event
    @team = Team.find(params[:team_id])
    @event = Event.find(params[:event_id])
    @result = Result.first(
      :include => { :scores => [ :source_result, :competition_result ] },
      :conditions => ['results.event_id = ? and team_id = ? and race_id = ?', params[:event_id], params[:team_id], params[:race_id]]
    )
    raise ActiveRecord::RecordNotFound unless @result
    expires_in 1.hour, :public => true
  end
  
  # Person's Results for an entire year
  def person
    @person = Person.find(params[:person_id])
    set_date_and_year
    @event_results = Result.all(
     :conditions => [ "person_id = ? and year = ? and competition_result = false and team_competition_result = false", @person.id, @date.year ]
    )
    @competition_results = Result.all(
     :include => { :scores => [ :source_result, :competition_result ] },
     :conditions => [ "person_id = ? and year = ? and (competition_result = true or team_competition_result = true)", @person.id, @date.year ]
    )
    expires_in 1.hour, :public => true
    render :layout => !request.xhr?
  end
  
  # Teams's Results for an entire year
  def team
    @team = Team.find(params[:team_id])
    set_date_and_year
    @results = Result.all(
      :conditions => [ "team_id = ? and year = ? and competition_result = false and team_competition_result = false", @team.id, @date.year ]
    )
    expires_in 1.hour, :public => true
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
