# frozen_string_literal: true

module Calculations
  class ResultsController < ApplicationController
    def index
      event_id = params[:event_id]
      @event = Event.find(event_id)
      @races = @event.races.includes(:category)
      @page = params[:page]

      @many_races = Result.where(event_id: event_id).distinct.count(:race_id) > 1
      many_results = Result.where(event_id: event_id).count > 500

      if many_results && @many_races
        race_id = @races.sort.first.id
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

    def race_results(race_id)
      Result
        .where(race_id: race_id)
        .where.not(place: "")
        .where.not(place: nil)
        .includes(race: :event)
    end
  end
end
