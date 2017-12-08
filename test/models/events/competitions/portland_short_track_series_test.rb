# frozen_string_literal: true

require "test_helper"

module Competitions
  # :stopdoc:
  class PortlandShortTrackSeriesTest < ActiveSupport::TestCase
    test "calculate" do
      weekly_series = FactoryBot.create(:weekly_series, name: "Portland Short Track Series")
      event = FactoryBot.create(:event, parent: weekly_series)
      event.races.create!(category: Category.create!(name: "Elite Men")).results.create!(place: 1, person: Person.new, age: 30)

      PortlandShortTrackSeries::Overall.calculate!
      PortlandShortTrackSeries::TeamStandings.calculate!
    end

    test "calculate upgrades" do
      weekly_series = FactoryBot.create(:weekly_series, name: "Portland Short Track Series")

      person = FactoryBot.create(:person)
      event = FactoryBot.create(:event, parent: weekly_series)
      event.races.create!(category: Category.create!(name: "Category 2 Women U45")).results.create!(place: 1, person: person)

      event = FactoryBot.create(:event, parent: weekly_series)
      event.races.create!(category: Category.create!(name: "Elite/Category 1 Women")).results.create!(place: 13, person: person)

      PortlandShortTrackSeries::Overall.calculate!

      overall = PortlandShortTrackSeries::Overall.first

      race = overall.races.detect { |r| r.name == "Category 2 Women U45" }
      assert_equal 1, race.results.size
      assert_equal 100, race.results.first.points

      race = overall.races.detect { |r| r.name == "Elite/Category 1 Women" }
      assert_equal 1, race.results.size
      assert_equal 70, race.results.first.points
    end
  end
end
