# frozen_string_literal: true

module Competitions
  class OregonWomensPrestigeSeriesController < ApplicationController
    def show
      @event = OregonWomensPrestigeSeries.find_for_year(@year) || OregonWomensPrestigeSeries.new
      @team_event = OregonWomensPrestigeTeamSeries.find_for_year(@year) || OregonWomensPrestigeTeamSeries.new

      request.session_options[:skip] = true
      unless @event.new_record?
        @event = OregonWomensPrestigeSeries
                 .includes(competition_event_memberships: :event)
                 .includes(races: %i[category results])
                 .find(@event.id)
      end

      unless @team_event.new_record?
        @team_event = OregonWomensPrestigeTeamSeries
                      .includes(races: %i[category results])
                      .find(@team_event.id)
      end
    end
  end
end
