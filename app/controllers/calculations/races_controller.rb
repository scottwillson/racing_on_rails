# frozen_string_literal: true

module Calculations
  class RacesController < ApplicationController
    def show
      @race = Race
              .where(id: params[:id])
              .includes(:category)
              .first!

      @event = @race.event
      @races = @event.races.includes(:category)

      @results = Result
                 .where(race_id: params[:id])
                 .includes(:person)

      @calculation = Calculations::V3::Calculation.find_by(event_id: @event.id)
    end
  end
end
