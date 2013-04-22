require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class OregonCupTest < ActiveSupport::TestCase
  def test_calculate
    # Oregon Cup
    # Men
    # 1. Tonkin     114
    # 2. Weaver      88
    # 3. Matson      60
    # 4. Molly      15
    
    # Women
    # 1. Alice       75
    # 2. Molly      15
    
    senior_men = FactoryGirl.create(:category, :name => "Senior Men")
    senior_men_p_1_2 = FactoryGirl.create(:category, :name => "Senior Men Pro 1/2", :parent => senior_men)
    senior_women = FactoryGirl.create(:category, :name => "Senior Women")
    # Set BAR point bonus -- it should be ignored
    kings_valley_2004 = FactoryGirl.create(:event, :date => Date.new(2004))
    kings_valley_pro_1_2 = kings_valley_2004.races.create!(:category => senior_men_p_1_2, :bar_points => 2)
    matson = FactoryGirl.create(:person)
    tonkin = FactoryGirl.create(:person)
    weaver = FactoryGirl.create(:person)
    molly = FactoryGirl.create(:person)
    alice = FactoryGirl.create(:person)
    kings_valley_pro_1_2.results.create!(:person => tonkin, :place => 16)
    kings_valley_pro_1_2.results.create!(:person => weaver, :place => 17)
    kings_valley_pro_1_2.results.create!(:person => molly, :place => 20)
    kings_valley_pro_1_2.results.create!(:person => matson, :place => 21)

    race = kings_valley_2004.races.create!(:category => senior_women, :notes => "For Oregon Cup", :bar_points => 0)
    race.results.create!(:person => alice, :place => 2)
    # Ignore Cat 4 result
    women_4 = FactoryGirl.create(:category, :name => "Women 4")
    race.results.create!(:place => 3, :person => Person.create!(:name => "Heather G", :member_from => Date.new(2004)), :category => women_4)
    race.results.create!(:person => molly, :place => 15)

    source_category = FactoryGirl.create(:category, :name => "Senior Women 1/2/3")

    # Sometimes women categories are picked separately. Ignore them.
    separate_category = FactoryGirl.create(:category, :name => "Senior Women 1/2")
    senior_women.children << separate_category
    separate_child_event = kings_valley_2004.children.create!(:bar_points => 1)
    separate_child_event.races.create!(:category => separate_category).results.create!(:place => "1", :person => molly)

    or_cup = OregonCup.create(:date => Date.new(2004))
    series = FactoryGirl.create(:series, :date => Date.new(2004, 3))
    banana_belt_1 = FactoryGirl.create(:event, :date => Date.new(2004, 3), :parent => series)
    race = banana_belt_1.races.create!(:category => senior_men_p_1_2)
    race.results.create!(:place => "1", :person => tonkin)
    race.results.create!(:place => "2", :person => weaver)
    race.results.create!(:place => "3", :person => matson)
    race.results.create!(:place => "16", :person => molly)

    or_cup.source_events << banana_belt_1
    or_cup.source_events << kings_valley_2004
    assert(or_cup.errors.empty?, "Oregon Cup errors #{or_cup.errors.full_messages}")
    assert(banana_belt_1.errors.empty?, "banana_belt_1 errors #{or_cup.errors.full_messages}")

    assert_difference "Result.count", 4 do
      OregonCup.calculate!(2004)
    end
    or_cup = OregonCup.first(:conditions => ['date = ?', Date.new(2004)])
    assert_not_nil(or_cup, 'Should have Oregon Cup for 2004')
    assert_equal(1, OregonCup.count, "Oregon Cup events after calculate!")
    
    or_cup.races.sort_by(&:name)
    races = or_cup.races.sort_by(&:name)
    races[0].results.sort!
    assert_equal(tonkin, races[0].results[0].person, "Senior Men Oregon Cup results person")
    assert_equal("1", races[0].results[0].place, "Tonkin Oregon Cup results place")
    assert_equal(114, races[0].results[0].points, "Tonkin Oregon Cup results points")
    assert_equal(2, races[0].results[0].scores.size, "Tonkin Oregon Cup results scores")

    assert_equal(weaver, races[0].results[1].person, "Senior Men Oregon Cup results person")
    assert_equal("2", races[0].results[1].place, "Weaver Oregon Cup results place")
    assert_equal(88, races[0].results[1].points, "Weaver Oregon Cup results points")
    assert_equal(2, races[0].results[1].scores.size, "Weaver Oregon Cup results scores")

    assert_equal(matson, races[0].results[2].person, "Senior Men Oregon Cup results person")
    assert_equal("3", races[0].results[2].place, "Matson Oregon Cup results place")
    assert_equal(60, races[0].results[2].points, "Matson Oregon Cup results points")
    assert_equal(1, races[0].results[2].scores.size, "Matson Oregon Cup results scores")

    assert_equal(molly, races[0].results[3].person, "Senior Men Oregon Cup results person")
    assert_equal("4", races[0].results[3].place, "Molly Oregon Cup results place")
    assert_equal(24, races[0].results[3].points, "Molly Oregon Cup results points")
    assert_equal(2, races[0].results[3].scores.size, "Molly Oregon Cup results scores")
  end
end
