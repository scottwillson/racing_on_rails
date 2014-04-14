class OregonWomensPrestigeSeriesController < ApplicationController
  def show
    @event = OregonWomensPrestigeSeries.find_for_year(@year) || OregonWomensPrestigeSeries.new
    @team_event = OregonWomensPrestigeTeamSeries.find_for_year(@year) || OregonWomensPrestigeTeamSeries.new

    request.session_options[:skip] = true
    if stale?(@team_event) || stale?(@event)
      if !@event.new_record?
        @event = OregonWomensPrestigeSeries.
                  includes(competition_event_memberships: :event).
                  includes(races: [ :category, :results ]).
                  find(@event.id)
      end

      if !@team_event.new_record?
        @team_event = OregonWomensPrestigeTeamSeries
          .includes(races: [ :category, :results ])
          .find(@team_event.id)
      end
    end
  end
end
