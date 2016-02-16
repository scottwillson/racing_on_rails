require "test_helper"

module Competitions
  # :stopdoc:
  class OregonWomensPrestigeSeriesTest < ActiveSupport::TestCase
    test "no results" do
      OregonWomensPrestigeSeries.calculate!
      competition = OregonWomensPrestigeSeries.find_for_year
      assert_equal 3, competition.races.count, "races"
      assert_same_elements [ "Women 1/2", "Women 3", "Women 4/5"], competition.races.map(&:name), "category names"
      assert competition.races.first.results.empty?, "should have no results"
    end

    test "calculate" do
      competition = OregonWomensPrestigeSeries.create!

      event_1 = FactoryGirl.create(:event)
      competition.source_events << event_1
      women_12 = Category.where(name: "Women 1/2").first
      race_event_1_women_12 = event_1.races.create!(category: women_12, bar_points: 0)
      women_3 = Category.where(name: "Women 3").first
      race_event_1_women_3 = event_1.races.create!(category: women_3)
      women_4_5 = Category.where(name: "Women 4/5").first!
      race_event_1_women_4_5 = event_1.races.create!(category: women_4_5)
      race_event_1_senior_men = FactoryGirl.create(:race, event: event_1)

      event_2 = FactoryGirl.create(:multi_day_event)
      competition.source_events << event_2
      race_event_2_women_4_5 = event_2.races.create!(category: women_4_5)
      race_event_2_women_12 = event_2.races.create!(category: women_12)

      event_3 = FactoryGirl.create(:event)
      competition.source_events << event_3
      women_123 = Category.create!(name: "Women 1/2/3")
      race_event_3_women_123 = event_3.races.create!(category: women_123)

      # scoring results
      result_1 = FactoryGirl.create(:result, race: race_event_1_women_12, place: 1)
      FactoryGirl.create(:result, race: race_event_1_women_4_5, place: 5)
      result_2 = FactoryGirl.create(:result, race: race_event_2_women_12, place: 15)
      FactoryGirl.create(:result, race: race_event_2_women_12, place: 16)
      FactoryGirl.create(:result, race: race_event_1_women_3, place: 3)

      # team event scoring result
      FactoryGirl.create(:result, race: race_event_3_women_123, place: 7, person_id: result_1.person_id)
      FactoryGirl.create(:result, race: race_event_3_women_123, place: 7, person_id: result_2.person_id)

      # Too low a place to score
      FactoryGirl.create(:result, race: race_event_2_women_4_5, place: 16)

      # Not a series category
      FactoryGirl.create(:result, race: race_event_1_senior_men, place: 4)

      # Not a series event
      FactoryGirl.create(:result, place: 2)

      OregonWomensPrestigeSeries.calculate!

      race = competition.races.find { |r| r.category == women_12 }
      assert_equal [ 25, 1.5 ], race.results.sort.map(&:points), "points for Women 1/2"

      race = competition.races.find { |r| r.category == women_3 }
      assert_equal [ 18 ], race.results.sort.map(&:points), "points for Women 3"

      race = competition.races.find { |r| r.category == women_4_5 }
      assert_equal [ 14 ], race.results.sort.map(&:points), "points for Women 4/5"
    end
  end
end
