# frozen_string_literal: true

# What appear to be duplicate finds are actually existence tests.
# Many methods to handle old URLs that search engines still hit. Will be removed.
class ResultsController < ApplicationController
  helper_method :competitions
  helper_method :events
  helper_method :weekly_series

  # HTML: Formatted links to Events with Results
  # == Params
  # * year (optional)
  def index
    @discipline = Discipline[params["discipline"]]
    @discipline_names = Discipline.names
    @calculations = Calculations::V3::Calculation.with_results(@year)

    respond_to do |format|
      format.html
      format.xml do
        fresh_when RacingAssociation.current, public: true
        all_events
      end
    end
  end

  # All Results for Event
  def event
    if params[:key]
      year = params[:year] || RacingAssociation.current.effective_year
      calculation = Calculations::V3::Calculation.find_by(key: params[:key], year: year)

      unless calculation
        flash[:info] = "No results for #{year}"
        calculation = Calculations::V3::Calculation.latest(params[:key])
      end

      raise(ActionController::RoutingError, "Calculation #{params[:key]} not found") unless calculation

      if calculation.event
        @event = calculation.event
      else
        flash[:info] = "No results for #{calculation.year}"
        return redirect_to(calculation_path(calculation))
      end
    else
      @event = Event.find_by(id: params[:event_id])
      return redirect_to(schedule_path) unless @event
    end

    respond_to do |format|
      format.html do
        ActiveSupport::Notifications.instrument "assign_data.event.results.racing_on_rails", event_id: @event.id, event_name: @event.name do
          assign_event_data
          assign_start_list
        end
      end
      format.json { render json: results_for_api(@event.id) }
      format.xml { render xml: results_for_api(@event.id) }
      format.xlsx do
        assign_event_data
        headers["Content-Disposition"] = 'filename="results.xlsx"'
        render :event
      end
    end
  end

  # Single Person's Results for a single Event
  def person_event
    @event = Event.find(params[:event_id])
    @person = Person.find(params[:person_id])
    @results = Result.person_event @person, @event
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "Could not find results for #{@event.try :name} #{@person.try :name}"
    redirect_to(people_path)
  end

  # Single Team's Results for a single Event
  def team_event
    @team = Team.find(params[:team_id])
    @event = Event.find(params[:event_id])
    @results = Result.team_event(@team, @event)
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "Could not find result for #{@event.try :name} #{@team.try :name}"
    redirect_to(teams_path)
  end

  # Person's Results for an entire year
  def person
    @person = Person.where(id: params[:person_id]).first

    respond_to do |format|
      format.html do
        if @person.nil?
          flash[:notice] = "No person with id #{params[:person_id]}"
          return redirect_to(people_path)
        end

        assign_person_results @person, @year
        render layout: !request.xhr?
      end

      format.json do
        return(render(status: :not_found, body: "")) unless @person

        assign_person_results @person, @year
        render json: (@event_results + @competition_results).to_json
      end

      format.xml do
        return(render(status: :not_found, body: "")) unless @person

        assign_person_results @person, @year
        render xml: (@event_results + @competition_results).to_xml
      end
    end
  end

  # Teams's Results for an entire year
  def team
    @team = Team.where(id: params[:team_id]).first
    respond_to do |format|
      format.html do
        if @team.nil?
          flash[:notice] = "No team with id #{params[:team_id]}"
          return redirect_to(teams_path)
        end

        assign_team_results @team, @year
        render layout: !request.xhr?
      end

      format.json do
        return(render(status: :not_found, body: "")) unless @team

        assign_team_results @team, @year
        render json: @event_results.to_json
      end

      format.xml do
        return(render(status: :not_found, body: "")) unless @team

        assign_team_results @team, @year
        render xml: @event_results.to_xml
      end
    end
  end

  private

  def all_events
    @all_events ||= Event.find_all_with_results(@year, @discipline)
  end

  def events
    @events ||= all_events.reject { |e| e.is_a?(Competitions::Competition) || e.is_a?(WeeklySeries) }
  end

  def weekly_series
    @weekly_series ||= all_events.select { |e| e.is_a?(WeeklySeries) }
  end

  def assign_person_results(person, year)
    @event_results = Result.where(
      person_id: person.id,
      year: year,
      competition_result: false,
      team_competition_result: false
    )
    @competition_results = Result
                           .includes(scores: %i[source_result competition_result])
                           .where(person_id: person.id, year: year)
                           .where("competition_result = true or team_competition_result = true")
                           .where.not(numeric_place: Result::UNPLACED)
  end

  def assign_team_results(team, year)
    @event_results = Result
                     .where(team_id: team.id, year: year)
                     .where("competition_result = false and team_competition_result = false")
                     .where.not(numeric_place: Result::UNPLACED)
  end

  # Default implementation. Return nil. Override in engines.
  def assign_start_list
    @start_list = nil
  end

  def results_for_api(event_id)
    Result.where(event_id: event_id)
  end

  def assign_event_data
    @source_events = if @event.source_events?
                       @event.source_events.include_results
                     else
                       Event.none
                     end

    @races = Race.where(event_id: @event.id).include_results
    @single_day_event_children = SingleDayEvent.where(parent_id: @event.id).include_child_results
    @children = Event.where(parent_id: @event.id).not_single_day_event.include_child_results
  end
end
