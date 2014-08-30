# What appear to be duplicate finds are actually existence tests.
# Many methods to handle old URLs that search engines still hit. Will be removed.
class ResultsController < ApplicationController
  caches_page :index, :event, :person, :person_event, :team

  # HTML: Formatted links to Events with Results
  # == Params
  # * year (optional)
  def index
    if stale?([ Event.maximum(:updated_at), @year ], public: true)
      @discipline = Discipline[params["discipline"]]
      @discipline_names = Discipline.names
      @weekly_series, @events, @competitions = Event.find_all_with_results(@year, @discipline)

      respond_to do |format|
        format.html
        format.xml
      end
    end
  end

  # All Results for Event
  def event
    @event = Event.find(params[:event_id])

    case @event
    when Competitions::AgeGradedBar, Competitions::Bar, Competitions::TeamBar
      return redirect_to(controller: "competitions/bar", action: "show", year: @event.year, discipline: @event.discipline)
    when Competitions::Cat4WomensRaceSeries
      return redirect_to(cat4_womens_race_series_path(year: @event.year))
    when Competitions::OverallBar
      return redirect_to(controller: "competitions/bar", action: "show", year: @event.year)
    when Competitions::Ironman
      return redirect_to(ironman_path(year: @event.year))
    when Competitions::OregonCup
      return redirect_to(oregon_cup_path(year: @event.year))
    when Competitions::RiderRankings
      return redirect_to(rider_rankings_path(year: @event.year))
    end

    respond_to do |format|
      format.html {
        benchmark "Load results", level: :debug do
          if stale?(@event, public: true)
            @event = Event.includes(races: [ :category, { results: :team } ]).find(params[:event_id])
          end
        end
        assign_start_list
      }
      format.json { render json: results_for_api(@event.id) }
      format.xml { render xml: results_for_api(@event.id) }
    end
  end

  # Single Person's Results for a single Event
  def person_event
    @event = Event.find(params[:event_id])
    @person = Person.find(params[:person_id])
    if stale?([ @event, @person, @year ], public: true)
      @results = Result.
                  includes(scores: [ :source_result, :competition_result ]).
                  where(event_id: params[:event_id]).
                  where(person_id: params[:person_id])
    end
  end

  # Single Team's Results for a single Event
  def team_event
    @team = Team.find(params[:team_id])
    @event = Event.find(params[:event_id])
    if stale?([ @event, @team, @year ], public: true)
      @result = Result.
                includes(scores: [ :source_result, :competition_result ]).
                where("results.event_id" => params[:event_id]).
                where(team_id: params[:team_id]).
                first!
      raise ActiveRecord::RecordNotFound unless @result
    end
  end

  # Person's Results for an entire year
  def person
    @person = Person.find(params[:person_id])

    respond_to do |format|
      format.html do
        if stale?([ @person, @year ], public: true)
          assign_person_results @person, @year
          render layout: !request.xhr?
        end
      end

      format.json do
        assign_person_results @person, @year
        render json: (@event_results + @competition_results).to_json
      end

      format.xml do
        assign_person_results @person, @year
         render xml: (@event_results + @competition_results).to_xml
      end
    end
  end

  # Teams's Results for an entire year
  def team
    @team = Team.find(params[:team_id])
    respond_to do |format|
      format.html do
        if stale?([ @team, @year ], public: true)
          assign_team_results @team, @year
          render layout: !request.xhr?
        end
      end

      format.json do
        assign_team_results @team, @year
        render json: @event_results.to_json
      end

      format.xml do
        assign_team_results @team, @year
        render xml: @event_results.to_xml
      end
    end
  end


  private

  def assign_events_with_results
    @weekly_series, @events, @competitions = Event.find_all_with_results(@year, @discipline)
  end

  def assign_person_results(person, year)
    @event_results = Result.where(
      "person_id = ? and year = ? and competition_result = false and team_competition_result = false", person.id, year
    )
    @competition_results = Result.
      includes(scores: [ :source_result, :competition_result ]).
      where("person_id = ? and year = ? and (competition_result = true or team_competition_result = true)", person.id, year)
  end

  def assign_team_results(team, year)
    @event_results = Result.where(team_id: team.id).where(year: year).where("competition_result = false and team_competition_result = false")
  end

  # Default implementation. Return nil. Override in engines.
  def assign_start_list
    @start_list = nil
  end

  def results_for_api(event_id)
    Result.where(event_id: event_id)
  end
end
