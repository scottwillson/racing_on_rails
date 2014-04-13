require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class OregonWomensPrestigeSeriesTest < ActiveSupport::TestCase
  test "no results" do
    OregonWomensPrestigeSeries.calculate!
    competition = OregonWomensPrestigeSeries.find_for_year
    assert_equal 2, competition.races.count, "races"
    assert_same_elements [ "Women 1/2/3", "Women 4"], competition.races.map(&:name), "category names"
    assert competition.races.first.results.empty?, "should have no results"
  end

  test "calculate" do
    competition = OregonWomensPrestigeSeries.create!

    event_1 = FactoryGirl.create(:event)
    competition.source_events << event_1
    women_123 = Category.where(:name => "Women 1/2/3").first
    race_event_1_women_123 = event_1.races.create!(:category => women_123, :bar_points => 0)
    women_4 = Category.where(:name => "Women 4").first
    race_event_1_women_4 = event_1.races.create!(:category => women_4)
    race_event_1_senior_men = FactoryGirl.create(:race, :event => event_1)

    event_2 = FactoryGirl.create(:multi_day_event)
    competition.source_events << event_2
    race_event_2_women_123 = event_2.races.create!(:category => women_123)
    race_event_2_women_4 = event_2.races.create!(:category => women_4)

    event_3 = FactoryGirl.create(:event)
    competition.source_events << event_3
    race_event_3_women_123 = event_3.races.create!(:category => women_123)

    # scoring results
    result_1 = FactoryGirl.create(:result, :race => race_event_1_women_123, :place => 1)
    FactoryGirl.create(:result, :race => race_event_1_women_4, :place => 5)
    result_2 = FactoryGirl.create(:result, :race => race_event_2_women_123, :place => 20)
    FactoryGirl.create(:result, :race => race_event_2_women_123, :place => 100)

    # team event scoring result
    FactoryGirl.create(:result, :race => race_event_3_women_123, :place => 7, :person_id => result_1.person_id)
    FactoryGirl.create(:result, :race => race_event_3_women_123, :place => 7, :person_id => result_2.person_id)

    # Too low a place to score
    FactoryGirl.create(:result, :race => race_event_2_women_4, :place => 101)

    # Not a series category
    FactoryGirl.create(:result, :race => race_event_1_senior_men, :place => 4)

    # Not a series event
    FactoryGirl.create(:result, :place => 2)

    OregonWomensPrestigeSeries.calculate!

    race = competition.races.find { |r| r.category == women_123 }
    assert_equal [ 122.5, 28.5, 3.0 ], race.results.sort.map(&:points), "points for Women 1/2/3"

    race = competition.races.find { |r| r.category == women_4 }
    assert_equal [ 55.0 ], race.results.sort.map(&:points), "points for Women 4"
  end
end
