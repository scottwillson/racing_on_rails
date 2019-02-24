# frozen_string_literal: true

module Calculations
  class ResultsController < ApplicationController
    def index
      if params[:event_id]
        event_id = params[:event_id]
        @event = Event.find(event_id)
        @races = Race.where(event_id: event_id).include_results
      elsif params[:race_id]
        @race = Race.find(params[:race_id])
        render :race
      else
        render :not_found
      end
    end
  end
end
