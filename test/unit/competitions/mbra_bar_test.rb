# FIXME Assert correct team names on BAR results

require "test_helper"

class MbraBarTest < ActiveSupport::TestCase
  def test_create
    date = Date.new(2006)
    bar = MbraBar.create!(
      :name => "#{date.year} Road BAR",
      :date => date,
      :discipline => Discipline[:track].name
    )
    assert_equal(2006, bar.year, "New BAR year")
  end
  
  def test_calculate
    # Lot of set-up for MbraBar. Keep it out of fixtures and do one-time here.
    
    original_results_count = Result.count

    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Road",
      :date => Date.new(2008, 5, 17)
    })
    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    swan_island_senior_men = swan_island.races.create(:category => senior_men, :field_size => 5)
    
    swan_island_senior_men.results.create({
      :place => 1,
      :person => people(:tonkin)
    })
    swan_island_senior_men.results.create({
      :place => 2,
      :person => people(:molly)
    })
    swan_island_senior_men.results.create({
      :place => 3,
      :person => people(:weaver)
    })
    swan_island_senior_men.results.create({
      :place => "dnf",
      :person => people(:alice)
    })
    swan_island_senior_men.results.create({
      :place => "dq",
      :person => people(:matson)
    })
    swan_island_senior_men.results.create({
      :place => "dns",
      :person => people(:member)
    })

    # single racer in category
    senior_women = Category.find_by_name("Senior Women")
    senior_women_swan_island = swan_island.races.create(:category => senior_women, :field_size => 1)
    senior_women_swan_island.results.create({
      :place => 1,
      :person => people(:molly)
    })

    assert_equal(0, MbraBar.count, "Bar before calculate!")
    MbraBar.calculate!(2008)
    assert_equal(6, MbraBar.count(:conditions => ['date = ?', Date.new(2008)]), "Bar events after calculate!")
    assert_equal(original_results_count + (6 + 4) + (1 + 1), Result.count, "Total count of results in DB")

    # Should delete old BAR
    MbraBar.calculate!(2008)
    assert_equal(6, MbraBar.count(:conditions => ['date = ?', Date.new(2008)]), "Bar events after calculate!")
    MbraBar.find(:all, :conditions => ['date = ?', Date.new(2008)]).each do |bar|
      assert(bar.name[/2008.*BAR/], "Name #{bar.name} is wrong")
      assert_equal_dates(Date.today, bar.updated_at, "BAR last updated")
    end
    assert_equal(original_results_count + (6 + 4) + (1 + 1), Result.count, "Total count of results in DB")

    road_bar = MbraBar.find_by_name("2008 Road BAR")
    men_road_bar = road_bar.races.detect {|b| b.name == "Senior Men" }
    assert_equal(categories(:senior_men), men_road_bar.category, "Senior Men BAR race BAR cat")
    assert_equal(4, men_road_bar.results.size, "Senior Men Road BAR results")

    men_road_bar.results.sort!
    assert_equal(people(:tonkin), men_road_bar.results[0].person, "Senior Men Road BAR results person")
    assert_equal("1", men_road_bar.results[0].place, "Senior Men Road BAR results place")
    assert_equal(5 + 6, men_road_bar.results[0].points, "Senior Men Road BAR results points")

    assert_equal(people(:weaver), men_road_bar.results[2].person, "Senior Men Road BAR results person")
    assert_equal("3", men_road_bar.results[2].place, "Senior Men Road BAR results place")
    assert_equal(3 + 1, men_road_bar.results[2].points, "Senior Men Road BAR results points")

    assert_equal(people(:alice), men_road_bar.results[3].person, "Senior Men Road BAR results person")
    assert_equal("4", men_road_bar.results[3].place, "Senior Men Road BAR results place - dnf")
    assert_equal(0.5, men_road_bar.results[3].points, "Senior Men Road BAR results points - dnf")

    women_road_bar = road_bar.races.detect {|b| b.name == "Senior Women" }
    assert_equal(categories(:senior_women), women_road_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(1, women_road_bar.results.size, "Senior Women Road BAR results")

    assert_equal(people(:molly), women_road_bar.results[0].person, "Senior Women Road BAR results person")
    assert_equal("1", women_road_bar.results[0].place, "Senior Women Road BAR results place")
    assert_equal((1 + 6), women_road_bar.results[0].points, "Senior Women Road BAR results points")

    #championship event - double points
    duck_island = SingleDayEvent.create!({
      :name => "Duck Island",
      :discipline => "Road",
      :date => Date.new(2008, 6, 17),
      :bar_points => 2
    })
#    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    duck_island_senior_men = duck_island.races.create(:category => senior_men, :field_size => 3)

    duck_island_senior_men.results.create({
      :place => 1,
      :person => people(:tonkin)
    })
    duck_island_senior_men.results.create({
      :place => 2,
      :person => people(:molly)
    })
    #two 2nd place racers both should get 2nd place points
    duck_island_senior_men.results.create({
      :place => 2,
      :person => people(:weaver)
    })

    senior_women_duck_island = duck_island.races.create(:category => senior_women, :field_size => 1)
    senior_women_duck_island.results.create({
      :place => 1,
      :person => people(:molly)
    })

    #these results should be dropped due to 70% of events rule
    goose_island = SingleDayEvent.create!({
      :name => "Goose Island",
      :discipline => "Road",
      :date => Date.new(2008, 7, 17)
    })
#    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    goose_island_senior_men = goose_island.races.create(:category => senior_men, :field_size => 2)

    goose_island_senior_men.results.create({
      :place => 1,
      :person => people(:tonkin)
    })
    goose_island_senior_men.results.create({
      :place => 2,
      :person => people(:molly)
    })
    senior_women_goose_island = goose_island.races.create(:category => senior_women, :field_size => 1)
    senior_women_goose_island.results.create({
      :place => 1,
      :person => people(:molly)
    })

    MbraBar.calculate!(2008)
    assert_equal(6, MbraBar.count(:conditions => ['date = ?', Date.new(2008)]), "Bar events after calculate!")
    assert_equal(original_results_count + (6 + 4) + (1 + 1) + 3 + 1 + 2 + 1, Result.count, "Total count of results in DB")

    road_bar = MbraBar.find_by_name("2008 Road BAR")
    men_road_bar = road_bar.races.detect {|b| b.name == "Senior Men" }
    assert_equal(categories(:senior_men), men_road_bar.category, "Senior Men BAR race BAR cat")
    assert_equal(4, men_road_bar.results.size, "Senior Men Road BAR results")

    men_road_bar.results.sort!
    assert_equal(people(:tonkin), men_road_bar.results[0].person, "Senior Men Road BAR results person")
    assert_equal("1", men_road_bar.results[0].place, "Senior Men Road BAR results place")
    assert_equal((5 + 6) + ((3 + 6) * 2), men_road_bar.results[0].points, "Senior Men Road BAR results points")

    assert_equal(people(:molly), men_road_bar.results[1].person, "Senior Men Road BAR results person")
    assert_equal("2", men_road_bar.results[1].place, "Senior Men Road BAR results place")
    assert_equal((4 + 3) + ((2 + 3) * 2), men_road_bar.results[1].points, "Senior Men Road BAR results points")

    assert_equal(people(:weaver), men_road_bar.results[2].person, "Senior Men Road BAR results person")
    assert_equal("3", men_road_bar.results[2].place, "Senior Men Road BAR results place")
    assert_equal((3 + 1) + ((2 + 3) * 2), men_road_bar.results[2].points, "Senior Men Road BAR results points")

    women_road_bar = road_bar.races.detect {|b| b.name == "Senior Women" }
    assert_equal(categories(:senior_women), women_road_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(1, women_road_bar.results.size, "Senior Women Road BAR results")

    assert_equal(people(:molly), women_road_bar.results[0].person, "Senior Women Road BAR results person")
    assert_equal("1", women_road_bar.results[0].place, "Senior Women Road BAR results place")
    assert_equal((1 + 6) + ((1 + 6) * 2), women_road_bar.results[0].points, "Senior Women Road BAR results points")


     # No BAR points
     egret_island = SingleDayEvent.create!({
      :name => "Egret Island",
      :discipline => "Road",
      :date => Date.new(2008, 7, 17),
      :bar_points => 0
    })
    senior_women_egret_island = egret_island.races.create(:category => senior_women, :field_size => 99)
    senior_women_egret_island.results.create({
      :place => 1,
      :person => people(:molly)
    })

    MbraBar.calculate!(2008)
    assert_equal(6, MbraBar.count(:conditions => ['date = ?', Date.new(2008)]), "Bar events after calculate!")
    assert_equal(original_results_count + (6 + 4) + (1 + 1) + 3 + 1 + 2 + 1 + 1, Result.count, "Total count of results in DB")

    road_bar = MbraBar.find_by_name("2008 Road BAR")
    women_road_bar = road_bar.races.detect {|b| b.name == "Senior Women" }
    assert_equal(categories(:senior_women), women_road_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(1, women_road_bar.results.size, "Senior Women Road BAR results")
    assert_equal(people(:molly), women_road_bar.results[0].person, "Senior Women Road BAR results person")
    assert_equal("1", women_road_bar.results[0].place, "Senior Women Road BAR results place")
    assert_equal((1 + 6) + ((1 + 6) * 2), women_road_bar.results[0].points, "Senior Women Road BAR results points")
  end

  def test_upgrade_scoring
    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Road",
      :date => Date.new(2008, 5, 17)
    })
    cat_4_women = Category.find_by_name("Cat 4 Women")
    cat_4_women_swan_island = swan_island.races.create(:category => cat_4_women, :field_size => 23)
    cat_4_women_swan_island.results.create({
      :place => 1,
      :person => people(:molly)
    })
    goose_island = SingleDayEvent.create!({
      :name => "Goose Island",
      :discipline => "Road",
      :date => Date.new(2008, 7, 17)
    })
    cat_1_2_3_women = Category.find_by_name("Cat 1/2/3 Women")
    cat_1_2_3_women_goose_island = goose_island.races.create(:category => cat_1_2_3_women, :field_size => 3)
    cat_1_2_3_women_goose_island.results.create({
      :place => 1,
      :person => people(:molly)
    })
#    cat_1_2_3_women_goose_island.results.create({
#      :place => 3,
#      :person => people(:alice)
#    })

    
    MbraBar.calculate!(2008)
    road_bar = MbraBar.find_by_name("2008 Road BAR")
    cat_4_women_road_bar = road_bar.races.detect {|b| b.name == "Cat 4 Women" }
    assert_equal(people(:molly), cat_4_women_road_bar.results[0].person, "Cat 4 Women Road BAR results person")
    assert_equal("1", cat_4_women_road_bar.results[0].place, "Cat 4 Women Road BAR results place")
    assert_equal((23 + 6), cat_4_women_road_bar.results[0].points, "Cat 4 Women Road BAR results points")

    cat_1_2_3_women_road_bar = road_bar.races.detect {|b| b.name == "Cat 1/2/3 Women" }
    assert_equal(people(:molly), cat_1_2_3_women_road_bar.results[0].person, "Cat 1/2/3 Women Road BAR results person")
    assert_equal("1", cat_1_2_3_women_road_bar.results[0].place, "Cat 1/2/3 Women Road BAR results place")
    assert_equal(((23 + 6) / 2).to_i + (3 + 6), cat_1_2_3_women_road_bar.results[0].points, "Cat 1/2/3 Women Road BAR results points")

    #test max 30 upgrade points
    duck_island = SingleDayEvent.create!({
      :name => "Duck Island",
      :discipline => "Road",
      :date => Date.new(2008, 6, 17)
    })
    cat_4_women_duck_island = duck_island.races.create(:category => cat_4_women, :field_size => 27)
    cat_4_women_duck_island.results.create({
      :place => 1,
      :person => people(:molly)
    })
    MbraBar.calculate!(2008)
    road_bar = MbraBar.find_by_name("2008 Road BAR")
    cat_4_women_road_bar = road_bar.races.detect {|b| b.name == "Cat 4 Women" }
    assert_equal(people(:molly), cat_4_women_road_bar.results[0].person, "Cat 4 Women Road BAR results person")
    assert_equal("1", cat_4_women_road_bar.results[0].place, "Cat 4 Women Road BAR results place")
    assert_equal((23 + 6) + (27 + 6), cat_4_women_road_bar.results[0].points, "Cat 4 Women Road BAR results points")

    cat_1_2_3_women_road_bar = road_bar.races.detect {|b| b.name == "Cat 1/2/3 Women" }
    assert_equal(people(:molly), cat_1_2_3_women_road_bar.results[0].person, "Cat 1/2/3 Women Road BAR results person")
    assert_equal("1", cat_1_2_3_women_road_bar.results[0].place, "Cat 1/2/3 Women Road BAR results place")
    assert_equal(30 + (3 + 6), cat_1_2_3_women_road_bar.results[0].points, "Cat 1/2/3 Women Road BAR results points")
  end
end