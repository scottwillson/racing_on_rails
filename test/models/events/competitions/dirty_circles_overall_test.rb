require "test_helper"

module Competitions
  # :stopdoc:
  class DirtyCirclesOverallTest < ActiveSupport::TestCase
    test "calculate" do
      series = Series.create!(name: "Dirty Circles")
      series.children.create!(date: Date.new(2016, 3,  8), name: "Dirty Circles 1")
      series.children.create!(date: Date.new(2016, 3, 15), name: "Dirty Circles 2")
      series.children.create!(date: Date.new(2016, 3, 22), name: "Dirty Circles 3")

      category = Category.create!(name: "Men 1/2/3")
      series.children.each do |event|
        event.races.create!(category: category)
      end

      winner = FactoryGirl.create(:person, name: "winner")
      event = series.children.first
      event.races.first.results.create!(place: "1", person: winner)

      hot_spot_winner = FactoryGirl.create(:person, name: "hot_spot_winner")
      event.races.first.results.create!(place: "2", person: hot_spot_winner)

      hot_spots = event.children.create!(name: "Hot Spots").races.create!(category: category)
      hot_spot_only = FactoryGirl.create(:person, name: "hot_spot_only")
      hot_spots.results.create!(place: "1", person: hot_spot_winner)
      hot_spots.results.create!(place: "2", person: hot_spot_only)

      DirtyCirclesOverall.calculate!

      overall = DirtyCirclesOverall.first
      results = overall.races.where(category: category).first.results
      assert_equal 3, results.count

      assert_equal winner, results[0].person
      assert_equal "1", results[0].place
      assert_equal 100, results[0].points

      assert_equal hot_spot_winner, results[1].person
      assert_equal "2", results[1].place
      assert_equal 98, results[1].points

      assert_equal hot_spot_only, results[2].person
      assert_equal "3", results[2].place
      assert_equal 16, results[2].points
    end
  end
end
