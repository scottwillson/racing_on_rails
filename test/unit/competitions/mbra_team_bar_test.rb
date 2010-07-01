require File.expand_path("../../../test_helper", __FILE__)

class MbraTeamBarTest < ActiveSupport::TestCase
  def test_create
    date = Date.new(2006)
    bar = MbraTeamBar.create!(
      :name => "#{date.year} Road BAT",
      :date => date,
      :discipline => Discipline[:road].name
    )
    assert_equal(2006, bar.year, "New BAT year")
  end

  def test_calculate
    # Lot of set-up for MbraTeamBar. Keep it out of fixtures and do one-time here.
   
    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Road",
      :date => Date.new(2008, 5, 17)
    })
    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    swan_island_senior_men = swan_island.races.create(:category => senior_men, :field_size => 6)

    swan_island_senior_men.results.create({
      :place => 1,
      :person => people(:tonkin),
      :team => teams(:kona)
    })
    swan_island_senior_men.results.create({
      :place => 2,
      :person => people(:weaver),
      :team => teams(:kona)
    })
    swan_island_senior_men.results.create({
      :place => 3,
      :person => people(:matson),
      :team => teams(:kona)
    })
    swan_island_senior_men.results.create({
      :place => 4,
      :person => people(:molly),
      :team => teams(:chocolate)
    }) #non-member team -> no bat results
    swan_island_senior_men.results.create({
      :place => 5,
      :person => people(:member)
    }) #no team -> no bat results
    swan_island_senior_men.results.create({
      :place => "dnf",
      :person => people(:alice),
      :team => teams(:gentle_lovers)
    })
    
    senior_women = Category.find_by_name("Senior Women")
    senior_women_swan_island = swan_island.races.create(:category => senior_women, :field_size => 3)
    senior_women_swan_island.results.create({
      :place => 1,
      :person => people(:tonkin),
      :team => teams(:kona)
    })
    # No BAT points
    senior_women_swan_island.bar_points = 0
    senior_women_swan_island.save!

    assert_equal(0, MbraTeamBar.count, "BAT events before calculate!")
    original_results_count = Result.count
    MbraTeamBar.calculate!(2008)
    assert_equal(6, MbraTeamBar.count(:conditions => ['date = ?', Date.new(2008)]), "BAT events after calculate!")
    assert_equal(original_results_count + 2, Result.count, "Total count of results in DB")

    road_bat = MbraTeamBar.find_by_name("2008 Road BAT")
    men_road_bat = road_bat.races.detect {|b| b.name == "Senior Men" }
    assert_equal(categories(:senior_men), men_road_bat.category, "Senior Men BAT race BAT cat")
    assert_equal(2, men_road_bat.results.size, "Senior Men Road BAT results")

    men_road_bat.results.sort!
    assert_equal(teams(:kona), men_road_bat.results[0].team, "Senior Men Road BAT results team")
    assert_equal("1", men_road_bat.results[0].place, "Senior Men Road BAT results place")
    assert_equal((6 + 6) + (5 + 3), men_road_bat.results[0].points, "Senior Men Road BAT results points")

    assert_equal(teams(:gentle_lovers), men_road_bat.results[1].team, "Senior Men Road BAT results team")
    assert_equal("2", men_road_bat.results[1].place, "Senior Men Road BAT results place")
    assert_equal(0.5, men_road_bat.results[1].points, "Senior Men Road BAT results points")

    women_road_bar = road_bat.races.detect {|b| b.name == "Senior Women" }
    assert_equal(categories(:senior_women), women_road_bar.category, "Senior Women BAT race BAT cat")
    assert_equal(0, women_road_bar.results.size, "Senior Women Road BAT results")

    #championship event - double points for bar but not bat
    duck_island = SingleDayEvent.create!({
      :name => "Duck Island",
      :discipline => "Road",
      :date => Date.new(2008, 6, 17),
      :bar_points => 2
    })
    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    duck_island_senior_men = duck_island.races.create(:category => senior_men, :field_size => 2)

    duck_island_senior_men.results.create({
      :place => 1,
      :person => people(:tonkin),
      :team => teams(:kona)
    })
    duck_island_senior_men.results.create({
      :place => 2,
      :person => people(:weaver),
      :team => teams(:gentle_lovers)
    }) #team change

    MbraTeamBar.calculate!(2008)
    assert_equal(6, MbraTeamBar.count(:conditions => ['date = ?', Date.new(2008)]), "BAT events after calculate!")
    assert_equal(original_results_count + 2 + 2, Result.count, "Total count of results in DB")

    road_bat = MbraTeamBar.find_by_name("2008 Road BAT")
    men_road_bat = road_bat.races.detect {|b| b.name == "Senior Men" }
    assert_equal(categories(:senior_men), men_road_bat.category, "Senior Men BAT race BAT cat")
    assert_equal(2, men_road_bat.results.size, "Senior Men Road BAT results")

    men_road_bat.results.sort!
    assert_equal(teams(:kona), men_road_bat.results[0].team, "Senior Men Road BAT results team")
    assert_equal("1", men_road_bat.results[0].place, "Senior Men Road BAT results place")
    assert_equal((6 + 6) + (5 + 3) + (2 + 6), men_road_bat.results[0].points, "Senior Men Road BAT results points")

    assert_equal(teams(:gentle_lovers), men_road_bat.results[1].team, "Senior Men Road BAT results team")
    assert_equal("2", men_road_bat.results[1].place, "Senior Men Road BAT results place")
    assert_equal(0.5 + (1 + 3), men_road_bat.results[1].points, "Senior Men Road BAT results points")

  end
end
