# What appear to be duplicate finds are actually existence tests.
# Many methods to handle old URLs that search engines still hit. Will be removed.
class ResultsController < ApplicationController
  caches_page :index, :event, :person, :person_event, :team, :if => Proc.new { |c| !mobile_request? }
  
  # HTML: Formatted links to Events with Results
  # == Params
  # * year (optional)
  def index
    @year = params['year'].to_i
    @year = Time.zone.today.year if @year == 0
    @discipline = Discipline[params['discipline']]
    @discipline_names = Discipline.names
    @weekly_series, @events, @competitions = Event.find_all_with_results(@year, @discipline)
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

    respond_to do |format|
      format.html {
        benchmark "Load results", :level => :debug do
          @event = Event.find(
            params[:event_id],
            :include => [ :races => [ :category, { :results => :team } ] ]
          )
        end
      }
      format.json { render :json => results_for_api(@event.id) }
      format.xml { render :xml => results_for_api(@event.id) }
    end
  end
  
  # Single Person's Results for a single Event
  def person_event
    @event = Event.find(params[:event_id])
    @person = Person.find(params[:person_id])
    @results = Result.all(
      :include => { :scores => [ :source_result, :competition_result ] },
      :conditions => ['results.event_id = ? and person_id = ?', params[:event_id], params[:person_id]]
    )
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
  end
  
  # Person's Results for an entire year
  def person
    @person = Person.find(params[:person_id])
    set_date_and_year
    @event_results = Result.where(
      "person_id = ? and year = ? and competition_result = false and team_competition_result = false", @person.id, @date.year
    )
    @competition_results = Result.
      includes(:scores => [ :source_result, :competition_result ]).
      where("person_id = ? and year = ? and (competition_result = true or team_competition_result = true)", @person.id, @date.year)
      
    respond_to do |format|
      format.html {render :layout => !request.xhr?}
      format.json { render :json => (@event_results + @competition_results).to_json }
      format.xml { render :xml => (@event_results + @competition_results).to_xml }
    end
  end
  
  # Teams's Results for an entire year
  def team
    @team = Team.find(params[:team_id])
    set_date_and_year
    @event_results = Result.where("team_id = ? and year = ? and competition_result = false and team_competition_result = false", @team.id, @date.year)
    respond_to do |format|
      format.html
      format.json { render :json => @event_results.to_json }
      format.xml { render :xml => @event_results.to_xml }
    end
  end
  
  
  private
  
  def set_date_and_year
    if params[:year] && params[:year][/\d\d\d\d/].present?
      @year = params[:year].to_i
    else
      @year = Time.zone.today.year
    end
    @date = Date.new(@year)
  end
  
  def results_for_api(event_id)
    Result.where(:event_id => event_id)
  end
end
