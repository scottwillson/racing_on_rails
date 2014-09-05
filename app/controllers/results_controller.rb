# What appear to be duplicate finds are actually existence tests.
# Many methods to handle old URLs that search engines still hit. Will be removed.
class ResultsController < ApplicationController
  caches_page :person, :person_event, :team

  helper_method :competitions
  helper_method :events
  helper_method :weekly_series

  # HTML: Formatted links to Events with Results
  # == Params
  # * year (optional)
  def index
    @discipline = Discipline[params["discipline"]]
    @discipline_names = Discipline.names

    respond_to do |format|
      format.html
      format.xml { all_events }
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
      format.html do
        ActiveSupport::Notifications.instrument "assign_data.event.results.racing_on_rails", event_id: @event.id, event_name: @event.name do
          @source_events = Event.none
          if @event.respond_to?(:source_events)
            @source_events = @event.source_events.include_results
          end

          @races = Race.where(event_id: @event.id).include_results
          @single_day_event_children = SingleDayEvent.where(parent_id: @event.id).include_child_results
          @children = Event.where(parent_id: @event.id).not_single_day_event.include_child_results
          assign_start_list
        end
      end
      format.json { render json: results_for_api(@event.id) }
      format.xml { render xml: results_for_api(@event.id) }
    end
  end

  # Single Person's Results for a single Event
  def person_event
    @event = Event.find(params[:event_id])
    @person = Person.find(params[:person_id])
    @results = Result.
                includes(scores: [ :source_result, :competition_result ]).
                where(event_id: params[:event_id]).
                where(person_id: params[:person_id])
  end

  # Single Team's Results for a single Event
  def team_event
    @team = Team.find(params[:team_id])
    @event = Event.find(params[:event_id])
    @result = Result.
              includes(scores: [ :source_result, :competition_result ]).
              where("results.event_id" => params[:event_id]).
              where(team_id: params[:team_id]).
              first!
    raise ActiveRecord::RecordNotFound unless @result
  end

  # Person's Results for an entire year
  def person
    @person = Person.find(params[:person_id])

    respond_to do |format|
      format.html do
        assign_person_results @person, @year
        render layout: !request.xhr?
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
        assign_team_results @team, @year
        render layout: !request.xhr?
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

  def all_events
    @all_events ||= Event.find_all_with_results(@year, @discipline)
  end

  def competitions
    @competitions ||= all_events.select { |e| e.is_a?(Competitions::Competition) }
  end

  def events
    @events ||= all_events.reject { |e| e.is_a?(Competitions::Competition) || e.is_a?(WeeklySeries) }
  end

  def weekly_series
    @weekly_series ||= all_events.select { |e| e.is_a?(WeeklySeries) }
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
