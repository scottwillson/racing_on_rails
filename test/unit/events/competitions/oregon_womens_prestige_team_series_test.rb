require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class OregonWomensPrestigeTeamSeriesTest < ActiveSupport::TestCase
  test "no results" do
    OregonWomensPrestigeTeamSeries.calculate!
    competition = OregonWomensPrestigeTeamSeries.find_for_year
    assert_equal 1, competition.races.count, "races"
    assert_same_elements [ "Team"], competition.races.map(&:name), "category names"
    assert competition.races.first.results.empty?, "should have no results"
  end

  test "calculate" do
    competition = OregonWomensPrestigeTeamSeries.create!

    event_1 = FactoryGirl.create(:event)
    competition.source_events << event_1
    women_123 = Category.where(:name => "Women 1/2/3").first_or_create
    race_event_1_women_123 = event_1.races.create!(:category => women_123)
    women_4 = Category.where(:name => "Women 4").first_or_create
    race_event_1_women_4 = event_1.races.create!(:category => women_4)
    race_event_1_senior_men = FactoryGirl.create(:race, :event => event_1)

    event_2 = FactoryGirl.create(:event)
    competition.source_events << event_2
    race_event_2_women_123 = event_2.races.create!(:category => women_123)
    race_event_2_women_4 = event_2.races.create!(:category => women_4)

    team_1 = FactoryGirl.create(:team)
    team_2 = FactoryGirl.create(:team)
    team_3 = FactoryGirl.create(:team)
    
    # scoring results
    FactoryGirl.create(:result, :race => race_event_1_women_123, :place => 1,   :team => team_1)
    FactoryGirl.create(:result, :race => race_event_1_women_123, :place => 2,   :team => team_1)
    FactoryGirl.create(:result, :race => race_event_1_women_123, :place => 9,   :team => team_1)
    FactoryGirl.create(:result, :race => race_event_1_women_123, :place => 6,   :team => team_1)
    FactoryGirl.create(:result, :race => race_event_1_women_4,   :place => 3,   :team => team_1)
    FactoryGirl.create(:result, :race => race_event_2_women_123, :place => 20,  :team => team_2)
    FactoryGirl.create(:result, :race => race_event_2_women_123, :place => 25,  :team => team_2)
    FactoryGirl.create(:result, :race => race_event_2_women_123, :place => 100, :team => team_3)
    FactoryGirl.create(:result, :race => race_event_2_women_123, :place => 5,   :team => team_1)
    
    # Too low a place to score
    FactoryGirl.create(:result, :race => race_event_2_women_4, :place => 101, :team => team_1)
    
    # Not a series category
    FactoryGirl.create(:result, :race => race_event_1_senior_men, :place => 4, :team => team_2)
    
    # Not a series event
    FactoryGirl.create(:result, :place => 2, :team => team_3)

    OregonWomensPrestigeTeamSeries.calculate!

    race = competition.races.find { |r| r.category.name == "Team" }
    assert_equal [ 305, 6, 2 ], race.results.sort.map(&:points), "points for Team race"
  end
end
