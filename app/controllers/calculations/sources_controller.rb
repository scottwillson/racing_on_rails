# frozen_string_literal: true

module Calculations
  class SourcesController < ApplicationController
    def index
      @race = Race
              .where(id: params[:race_id])
              .includes(:category)
              .first!

      @event = @race.event

      @calculation = Calculations::V3::Calculation
                     .where(event_id: @event.id)
                     .includes(calculation_categories: :category)
                     .first!

      @results = Result
                 .where(race_id: params[:race_id])
                 .includes(:person)
                 .includes(sources: [source_result: { race: :event }])
    end
  end
end
