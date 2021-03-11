# frozen_string_literal: true

module Calculations
  class ResultsController < ApplicationController
    def index
      if params[:key]
        year = params[:year] || Time.zone.today.year
        calculation = Calculations::V3::Calculation.find_by(key: params[:key], year: year)

        unless calculation
          flash[:info] = "No results for #{year}"
          calculation = Calculations::V3::Calculation.latest(params[:key])
        end

        raise(ActionController::RoutingError, "Calculation #{params[:key]} not found") unless calculation

        if calculation.event
          return redirect_to(calculations_event_results_path(event_id: calculation.event_id))
        end

        flash[:info] = "No results for #{calculation.year}"
        return redirect_to(calculation_path(calculation))
      end

      event_id = params[:event_id]
      @event = Event.find(event_id)
      @calculation = Calculations::V3::Calculation.find_by(event_id: @event.id)
      return redirect_to(event_path(@event)) unless @calculation

      @page = params[:page]

      race_ids = Result.where(event_id: event_id).distinct.pluck(:race_id)
      @races = @event.races.includes(:category).find(race_ids)
      @many_races = race_ids.many?
      many_results = Result.where(event_id: event_id).count > page_size

      if many_results && @many_races
        race_id = @races.min.id
        @results = race_results(race_id).paginate(page: @page, per_page: 200).order(:numeric_place)
        render :paginated
      elsif many_results
        @results = event_results(event_id).paginate(page: @page, per_page: 200).order(:numeric_place)
        render :paginated
      else
        @results = event_results(event_id)
      end
    end

    def show
      @result = Result
                .where(id: params[:id])
                .includes(:person)
                .includes(sources: [source_result: { race: :event }])
                .first!

      @race = Race
              .where(id: @result.race_id)
              .includes(:category)
              .first!

      @event = @race.event
      @races = @event.races.includes(:category)

      @calculation = Calculations::V3::Calculation
                     .where(event_id: @event.id)
                     .includes(calculation_categories: :category)
                     .first!

      render :show
    end

    private

    def event_results(event_id)
      Result
        .where(event_id: event_id)
        .where.not(place: "")
        .where.not(place: nil)
        .includes(race: :event)
    end

    # Intended for testing
    def page_size
      params[:page_size]&.to_i || 500
    end

    def race_results(race_id)
      Result
        .where(race_id: race_id)
        .where.not(place: "")
        .where.not(place: nil)
        .includes(race: :event)
    end
  end
end
