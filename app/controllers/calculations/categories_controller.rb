# frozen_string_literal: true

module Calculations
  class CategoriesController < ApplicationController
    def index
      @event = Event
               .where(id: params[:event_id])
               .includes(races: :category)
               .includes(races: { results: { sources: { source_result: { race: [:category, { event: :parent }] } } } })
               .first!

      @source_result_events = @event.source_result_events
      @rejected_events = Event.current_year - @source_result_events
    end
  end
end
