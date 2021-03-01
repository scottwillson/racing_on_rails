# frozen_string_literal: true

module Calculations
  class CategoriesController < ApplicationController
    def index
      @event = Event
               .includes(races: [:category, { event: { parent: :parent } }])
               .where(id: params[:event_id])
               .first!

      return redirect_to(event_results_path(@event)) unless @event.calculation

      @source_result_events = @event.source_result_events
      event_ids = Result.year(@event.year).pluck(:event_id).uniq
      @rejected_events = @event.calculation.source_events.where(id: event_ids).includes(parent: :parent) - @source_result_events
    end
  end
end
