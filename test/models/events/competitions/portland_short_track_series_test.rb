require "test_helper"

module Competitions
  # :stopdoc:
  class PortlandShortTrackSeriesTest < ActiveSupport::TestCase
    test "calculate" do
      weekly_series = FactoryGirl.create(:weekly_series, name: "Portland Short Track Series MTB STXC")
      weekly_series.races.create!(category: Category.create!(name: "Pro")).results.create!(place: 1, person: Person.new)
      
      PortlandShortTrackSeries::Overall.calculate!
      PortlandShortTrackSeries::MonthlyStandings.calculate!
      PortlandShortTrackSeries::TeamStandings.calculate!
    end
  end
end
