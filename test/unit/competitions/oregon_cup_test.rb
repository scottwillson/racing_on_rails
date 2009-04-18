require "test_helper"

class OregonCupTest < ActiveSupport::TestCase
  def test_create
    assert_nil(OregonCup.find(:first, :conditions => ['date = ?', Date.new(2003)]), 'Should have no Oregon Cup for 2003')
    or_cup = OregonCup.create!(:date => Date.new(2003))
    assert(or_cup.errors.empty?, "New OR Cup should have no errors, but has: #{or_cup.errors.full_messages}")
    assert_equal(2, or_cup.races.size, 'races')
    or_cup.races.sort_by {|s| s.name }

    sr_p_1_2 = or_cup.races.first
    assert_equal('Senior Men', sr_p_1_2.category.name, 'Senior men category')
    assert(sr_p_1_2.results.empty?, 'Senior men results.empty?')

    senior_women = or_cup.races.last
    assert_equal('Senior Women', senior_women.category.name, 'Senior women category')
    assert(senior_women.results.empty?, 'Senior women results.empty?')
  end
  
  def test_events
    or_cup = OregonCup.create!(:date => Date.new(2004))
    assert_equal(0, or_cup.source_events.count, 'Events for new Oregon Cup')
    
    or_cup.source_events << events(:banana_belt_1)
    assert_equal(1, or_cup.source_events.count, 'Events for new Oregon Cup')
    or_cup.source_events << events(:kings_valley)
    assert_equal(2, or_cup.source_events.count, 'Events for new Oregon Cup')
  end
  
  def test_calculate
    # 2004
    # Banana Belt Pro/1/2
    # 1. Tonkin
    # 2. Weaver
    # 3. Matson
    # 16. Molly
    
    # Kings Valley Pro 1/2 (2004, same as 2003)
    # 16. Tonkin (not fixture)
    # 17. Weaver (not fixture)
    # 20. Molly (not fixture)
    # 21. Matson (not fixture)
    
    # Kings Valley women
    # 2. Alice
    # 15. Molly
    
    # Oregon Cup
    # Men
    # 1. Tonkin     114
    # 2. Weaver      88
    # 3. Matson      60
    # 4. Molly      15
    
    # Women
    # 1. Alice       75
    # 2. Molly      15
    
    kings_valley_pro_1_2 = races(:kings_valley_pro_1_2_2004)
    matson = racers(:matson)
    tonkin = racers(:tonkin)
    weaver = racers(:weaver)
    molly = racers(:molly)
    kings_valley_pro_1_2.results.create!(:racer => tonkin, :place => 16)
    kings_valley_pro_1_2.results.create!(:racer => weaver, :place => 17)
    kings_valley_pro_1_2.results.create!(:racer => molly, :place => 20)
    kings_valley_pro_1_2.results.create!(:racer => matson, :place => 21)
    
    # Set BAR point bonus -- it should be ignored
    kings_valley_pro_1_2.bar_points = 2
    kings_valley_pro_1_2.save!
    
    category = Category.find_or_create_by_name('Senior Men')
    source_category = Category.find_or_create_by_name('Senior Men Pro 1/2')
    
    category = Category.find_or_create_by_name('Senior Women')
    source_category = Category.find_or_create_by_name('Senior Women 1/2/3')
    
    # Sometimes women categories are picked separately. Ignore them.
    separate_category = Category.find_or_create_by_name('Senior Women 1/2')
    category.children << separate_category
    separate_child_event = events(:kings_valley).children.create!(:bar_points => 1)
    separate_child_event.races.create!(:category => separate_category).results.create!(:place => "1", :racer => molly)
    womens_race = races(:kings_valley_women_2004)
    womens_race.notes = "For Oregon Cup"
    womens_race.bar_points = 0
    womens_race.save!
    
    or_cup = OregonCup.create(:date => Date.new(2004))
    banana_belt_1 = events(:banana_belt_1)
    or_cup.source_events << banana_belt_1
    or_cup.source_events << events(:kings_valley_2004)
    assert(or_cup.errors.empty?, "Oregon Cup errors #{or_cup.errors.full_messages}")
    assert(banana_belt_1.errors.empty?, "banana_belt_1 errors #{or_cup.errors.full_messages}")

    assert_equal(1, OregonCup.count, "Oregon Cups before calculate!")
    OregonCup.calculate!(2004)
    assert_equal(1, OregonCup.count, "Oregon Cup events after calculate!")
    or_cup = OregonCup.find(:first, :conditions => ['date = ?', Date.new(2004)])
    assert_not_nil(or_cup, 'Should have Oregon Cup for 2004')
    assert_equal(2, or_cup.source_events.count, "Oregon Cup events after calculate!")
    results = 0
    for race in or_cup.races
      results = results + race.results.size
    end
    assert_equal(6, results, "Oregon Cup results after calculate!")

    OregonCup.calculate!(2004)
    or_cup = OregonCup.find(:first, :conditions => ['date = ?', Date.new(2004)])
    assert_not_nil(or_cup, 'Should have Oregon Cup for 2004')
    assert_equal(1, OregonCup.count, "Oregon Cup events after calculate!")
    results = 0
    for race in or_cup.races
      results = results + race.results.size
    end
    assert_equal(6, results, "Oregon Cup results after calculate!")
    
    or_cup.races.sort_by {|s| s.name }
    races = or_cup.races.sort_by {|s| s.name }
    races[0].results.sort!
    assert_equal(racers(:tonkin), races[0].results[0].racer, "Senior Men Oregon Cup results racer")
    assert_equal("1", races[0].results[0].place, "Tonkin Oregon Cup results place")
    assert_equal(114, races[0].results[0].points, "Tonkin Oregon Cup results points")
    assert_equal(2, races[0].results[0].scores.size, "Tonkin Oregon Cup results scores")

    assert_equal(racers(:weaver), races[0].results[1].racer, "Senior Men Oregon Cup results racer")
    assert_equal("2", races[0].results[1].place, "Weaver Oregon Cup results place")
    assert_equal(88, races[0].results[1].points, "Weaver Oregon Cup results points")
    assert_equal(2, races[0].results[1].scores.size, "Weaver Oregon Cup results scores")

    assert_equal(racers(:matson), races[0].results[2].racer, "Senior Men Oregon Cup results racer")
    assert_equal("3", races[0].results[2].place, "Matson Oregon Cup results place")
    assert_equal(60, races[0].results[2].points, "Matson Oregon Cup results points")
    assert_equal(1, races[0].results[2].scores.size, "Matson Oregon Cup results scores")

    assert_equal(racers(:molly), races[0].results[3].racer, "Senior Men Oregon Cup results racer")
    assert_equal("4", races[0].results[3].place, "Molly Oregon Cup results place")
    assert_equal(24, races[0].results[3].points, "Molly Oregon Cup results points")
    assert_equal(2, races[0].results[3].scores.size, "Molly Oregon Cup results scores")

    races[1].results.sort!
    assert_equal(racers(:alice), races[1].results[0].racer, "Senior Women Oregon Cup results racer")
    assert_equal("1", races[1].results[0].place, "Alice Oregon Cup results place")
    assert_equal(75, races[1].results[0].points, "Alice Oregon Cup results points")
    assert_equal(1, races[1].results[0].scores.size, "Alice Oregon Cup results scores")

    assert_equal(racers(:molly), races[1].results[1].racer, "Senior Women Oregon Cup results racer")
    assert_equal("2", races[1].results[1].place, "Molly Oregon Cup results place")
    assert_equal(15, races[1].results[1].points, "Molly Oregon Cup results points")
    assert_equal(1, races[1].results[1].scores.size, "Molly Oregon Cup results scores")
  end
  
  def test_latest_event_with_results
    or_cup = OregonCup.new
    assert_nil(or_cup.latest_event_with_results, 'Should have no event with results')
    
    # Previous year
    or_cup = OregonCup.create!(:date => Date.new(2004))
    or_cup.source_events << events(:banana_belt_1)
    or_cup.source_events << events(:kings_valley)

    or_cup = OregonCup.create!
    assert_nil(or_cup.latest_event_with_results, 'Should have no event with result')
    
    event = SingleDayEvent.create!
    race = event.races.create!(:category => categories(:sr_p_1_2))
    race.results.create!(:place => '1', :racer => racers(:tonkin))
    or_cup = OregonCup.create!
    or_cup.source_events << event
    or_cup.source_events << SingleDayEvent.create!
    or_cup.source_events << SingleDayEvent.create!

    or_cup.reload
    assert_not_nil(or_cup.latest_event_with_results, 'Should have event with results')
    assert_equal(event, or_cup.latest_event_with_results, 'Latest OR Cup event with result')
  end
  
  def test_next_event
    or_cup = OregonCup.new
    assert(!or_cup.more_events?, 'More events')
    assert_nil(or_cup.next_event, 'Should have no next event')
    
    # Previous year
    or_cup = OregonCup.create!(:date => Date.new(2004))
    or_cup.source_events << events(:banana_belt_1)
    or_cup.source_events << events(:kings_valley)
    or_cup.save!

    or_cup = OregonCup.new
    assert(!or_cup.more_events?, 'More events')
    assert_nil(or_cup.next_event, 'Should have no next_event')
    
    or_cup = OregonCup.create!
    event = SingleDayEvent.new(:date => Date.today - 21)
    or_cup.source_events << event
    or_cup.reload
    assert(!or_cup.more_events?, 'More events')
    assert_nil(or_cup.next_event, 'Should have no next_event')

    event_2 = SingleDayEvent.new(:date => Date.today + 3)
    event_3 = SingleDayEvent.new(:date => Date.today + 30)
    or_cup.source_events << event_2
    or_cup.source_events << event_3
    or_cup.save!

    or_cup.reload
    assert(or_cup.more_events?, 'More events')
    assert_not_nil(or_cup.next_event, 'Should have next_event')
    assert_equal(event_2, or_cup.next_event, 'Next OR Cup event')
  end
end
