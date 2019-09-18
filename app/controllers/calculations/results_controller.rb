# frozen_string_literal: true

module Calculations
  class ResultsController < ApplicationController
    def index
      if params[:event_id]
        event_id = params[:event_id]
        @event = Event.find(event_id)
        @races = Race
                 .where(event_id: event_id)
                 .where.not(results: { place: "" })
                 .where.not(results: { place: nil })
                 .includes(:category, results: [:person, :team, { sources: :source_result }])

      elsif params[:race_id]
        @race = Race
                .where(id: params[:race_id])
                .includes(:category)
                .first!

        @calculation = Calculations::V3::Calculation
                       .where(event_id: @race.event_id)
                       .includes(calculation_categories: :category)
                       .first!

        @results = Result
                   .where(race_id: params[:race_id])
                   .includes(:person)
                   .includes(sources: [source_result: { race: :event }])

        render :race
      else
        render :not_found
      end
    end
  end
end
