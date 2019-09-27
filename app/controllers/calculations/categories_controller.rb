# frozen_string_literal: true

module Calculations
  class CategoriesController < ApplicationController
    def index
      @event = Event
               .includes(races: [:category, { event: { parent: :parent } }])
               .where(id: params[:event_id])
               .first!

      @source_result_events = @event.source_result_events
      @rejected_events = Event.current_year.includes(parent: :parent) - @source_result_events
    end
  end
end
