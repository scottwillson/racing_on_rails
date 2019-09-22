# frozen_string_literal: true

module Calculations
  class ResultsController < ApplicationController
    def index
      event_id = params[:event_id]
      @event = Event.find(event_id)
      @races = @event.races.includes(:category)
      @page = params[:page]

      many_races = Result.where(event_id: event_id).distinct.count(:race_id) > 1
      many_results = Result.where(event_id: event_id).count > 500

      if many_results && many_races
        render :races
      elsif many_results
        @results = results(event_id).paginate(page: @page, per_page: 200).order(:numeric_place)
        render :paginated
      else
        @results = results(event_id)
      end
    end

    private

    def results(event_id)
      Result
        .where(event_id: event_id)
        .where.not(place: "")
        .where.not(place: nil)
        .includes(race: :event)
    end
  end
end
