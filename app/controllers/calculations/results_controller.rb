# frozen_string_literal: true

module Calculations
  class ResultsController < ApplicationController
    def index
      event_id = params[:event_id]
      @event = Event.find(event_id)
      @races = Race.where(event_id: event_id).include_results
    end
  end
end
