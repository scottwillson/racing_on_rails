class OregonWomensPrestigeSeriesController < ApplicationController
  def show
    @event = OregonWomensPrestigeSeries.find_for_year(@year) || OregonWomensPrestigeSeries.new
    @team_event = OregonWomensPrestigeTeamSeries.find_for_year(@year) || OregonWomensPrestigeTeamSeries.new
  end
end
