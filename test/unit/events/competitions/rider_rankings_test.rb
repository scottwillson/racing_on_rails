require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class RiderRankingsTest < ActiveSupport::TestCase
  def test_calculate
    association        = FactoryGirl.create(:category, :name => "CBRA")
    men_cat_1_2        = FactoryGirl.create(:category, :name => "Men Cat 1-2", :parent => association)
    senior_men         = FactoryGirl.create(:category, :name => "Senior Men", :parent => men_cat_1_2)
    sr_p_1_2           = FactoryGirl.create(:category, :name => "Senior Pro/1/2", :parent => men_cat_1_2)
    men_a              = FactoryGirl.create(:category, :name => "Men A", :parent => men_cat_1_2)
    women_cat_1_2      = FactoryGirl.create(:category, :name => "Women Cat 1-2", :parent => association)
    senior_women_1_2_3 = FactoryGirl.create(:category, :name => "Senior Women 1/2/3", :parent => women_cat_1_2)
    women_cat_3        = FactoryGirl.create(:category, :name => "Women Cat 3", :parent => association)
    
    tonkin = FactoryGirl.create(:person, :name => "Tonkin")
    weaver = FactoryGirl.create(:person, :name => "Weaver")
    alice  = FactoryGirl.create(:person, :name => "Alice")
    molly  = FactoryGirl.create(:person, :name => "Molly")
    matson = FactoryGirl.create(:person, :name => "Matson")

    cross_crusade = Series.create!(:name => "Cross Crusade")
    barton = SingleDayEvent.create!(
      :name => "Cross Crusade: Barton Park",
      :discipline => "Cyclocross",
      :date => Date.new(2004, 11, 7),
      :parent => cross_crusade
    )
    barton_a = barton.races.create!(:category => men_a, :field_size => 5)
    barton_a.results.create!(
      :place => 3,
      :person => tonkin
    )
    barton_a.results.create!(
      :place => 10,
      :person => weaver
    )
    
    swan_island = SingleDayEvent.create!(
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    )
    swan_island_senior_men = swan_island.races.create!(:category => senior_men, :field_size => 4)
    swan_island_senior_men.results.create!(
      :place => 8,
      :person => tonkin
    )
    swan_island_senior_men.results.create!(
      :place => 2,
      :person => molly
    )
    senior_women_swan_island = swan_island.races.create!(:category => senior_women_1_2_3, :field_size => 3, :bar_points => 0)
    senior_women_swan_island.results.create!(
      :place => 1,
      :person => molly
    )
    # No points
    
    thursday_track_series = Series.create!(:name => "Thursday Track")
    thursday_track = SingleDayEvent.create!(
      :name => "Thursday Track",
      :discipline => "Track",
      :date => Date.new(2004, 5, 12),
      :parent => thursday_track_series
    )
    thursday_track_senior_men = thursday_track.races.create!(:category => senior_men, :field_size => 6)
    r = thursday_track_senior_men.results.create!(
      :place => 5,
      :person => weaver
    )
    thursday_track_senior_men.results.create!(
      :place => 10,
      :person => tonkin
    )
    
    team_track = SingleDayEvent.create!(
      :name => "Team Track State Championships",
      :discipline => "Track",
      :date => Date.new(2004, 9, 1),
      :bar_points => 2
    )
    team_track_senior_men = team_track.races.create!(:category => senior_men, :field_size => 6)
    team_track_senior_men.results.create!(
      :place => 1,
      :person => weaver
    )
    team_track_senior_men.results.create!(
      :place => 1,
      :person => tonkin
    )
    team_track_senior_men.results.create!(
      :place => 1,
      :person => molly
    )
    team_track_senior_men.results.create!(
      :place => 5,
      :person => alice
    )
    team_track_senior_men.results.create!(
      :place => 5,
      :person => matson
    )
    # Weaver and Erik"s second ride should not count
    team_track_senior_men.results.create!(
      :place => 10,
      :person => weaver
    )
    team_track_senior_men.results.create!(
      :place => 10,
      :person => tonkin
    )
    
    larch_mt_hillclimb = SingleDayEvent.create!(
      :name => "Larch Mountain Hillclimb",
      :discipline => "Time Trial",
      :date => Date.new(2004, 2, 1)
    )
    larch_mt_hillclimb_senior_men = larch_mt_hillclimb.races.create!(:category => senior_men, :field_size => 6)
    # Should bump Tonkin result up one place to fifth. In real life, we"d have all results 1-5, too
    non_member = Person.create!(:name => "Non Member", :member => false)
    larch_mt_hillclimb_senior_men.results.create!(
      :place => 3,
      :person => non_member
    )
    larch_mt_hillclimb_senior_men.results.create!(
      :place => 6,
      :person => tonkin
    )

    event = FactoryGirl.create(:event, :date => Date.new(2004), :name => "Banana Belt")
    race = event.races.create!(:category => sr_p_1_2)
    race.results.create!(:place => "1", :members_only_place => "1", :person => tonkin)
    race.results.create!(:place => "2", :members_only_place => "2", :person => weaver)
    race.results.create!(:place => "3", :members_only_place => "3", :person => matson)
    race = event.races.create!(:category => women_cat_3)
    race.results.create!(:place => "2", :members_only_place => "2", :person => alice)
    race.results.create!(:place => "15", :members_only_place => "15", :person => molly)

    # need to fill in any gaps in results to prevent place_members_only errors
    fill_in_missing_results      
    original_results_count = Result.count
    RiderRankings.calculate!(2004)
    assert_equal(1, RiderRankings.count, "RiderRankings events after calculate!")
    rider_rankings = RiderRankings.first(:conditions => ["date = ?", Date.new(2004, 1, 1)])
    assert_equal(19, rider_rankings.races.count, "RiderRankings races after calculate!")
    assert_not_nil(rider_rankings, "2004 RiderRankings after calculate!")
    assert_equal(Date.new(2004, 1, 1), rider_rankings.date, "2004 RiderRankings date")
    assert_equal("2004 Rider Rankings", rider_rankings.name, "2004 RiderRankings name")
    assert_equal_dates(Time.zone.today, rider_rankings.updated_at, "RiderRankings last updated")
    assert_equal(19, rider_rankings.races.size, "2004 rider rankings races")
    assert_equal_dates(Time.zone.today, rider_rankings.updated_at, "RiderRankings last updated")
    assert_equal(original_results_count + 6, Result.count, "Total count of results in DB")
    
    senior_men = rider_rankings.races.detect { |b| b.category == men_cat_1_2 }
    assert_equal(5, senior_men.results.size, "Senior Men rider rankings results")
    assert_equal_dates(Time.zone.today, senior_men.updated_at, "RiderRankings last updated")

    senior_men.results.sort!
    assert_equal(tonkin, senior_men.results[0].person, "Senior Men rider rankings results person")
    assert_equal("1", senior_men.results[0].place, "Senior Men rider rankings results place")
    assert_in_delta(259.333, senior_men.results[0].points, 0.001, "Senior Men rider rankings results points")

    assert_equal(weaver, senior_men.results[1].person, "Senior Men rider rankings results person")
    assert_equal("2", senior_men.results[1].place, "Senior Men rider rankings results place")
    assert_in_delta(155.333, senior_men.results[1].points, 0.001, "Senior Men rider rankings results points")
    assert_equal(4, senior_men.results[1].scores.size, "Weaver rider rankings results scores")

    assert_equal(matson, senior_men.results[3].person, "Senior Men rider rankings results person")
    assert_equal("4", senior_men.results[3].place, "Senior Men rider rankings results place")
    assert_equal(68, senior_men.results[3].points, "Senior Men rider rankings results points")
    
    women = rider_rankings.races.detect {|b| b.category == women_cat_3}
    assert_equal(1, women.results.size, "Cat 3 rider rankings results")

    women.results.sort!
    assert_equal(alice, women.results[0].person, "Senior Women rider rankings results person")
    assert_equal("1", women.results[0].place, "Senior Women rider rankings results place")
    assert_equal(70, women.results[0].points, "Senior Women rider rankings results points")
  end
end
