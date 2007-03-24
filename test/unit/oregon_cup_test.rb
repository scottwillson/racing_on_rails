require File.dirname(__FILE__) + '/../test_helper'

class OregonCupTest < Test::Unit::TestCase
  
  def test_new
    OregonCup.new
  end
  
  def test_create
    assert_nil(OregonCup.find(:first, :conditions => ['date = ?', Date.new(2003)]), 'Should have no Oregon Cup for 2003')
    or_cup = OregonCup.create(:date => Date.new(2003))
    assert_equal(1, or_cup.standings.size, 'Should create standings') 
    standings = or_cup.standings.first
    assert_equal(2, standings.races.size, 'standings races')
    standings.races.sort_by {|s| s.name }

    sr_p_1_2 = standings.races.first
    assert_equal('Senior Men', sr_p_1_2.category.name, 'Senior men category')
    assert(sr_p_1_2.results.empty?, 'Senior men results.empty?')

    sr_women = standings.races.last
    assert_equal('Senior Women', sr_women.category.name, 'Senior women category')
    assert(sr_women.results.empty?, 'Senior women results.empty?')
  end
  
  def test_events
    or_cup = OregonCup.create(:date => Date.new(2004))
    assert_equal(0, or_cup.events.count, 'Events for new Oregon Cup')
    
    or_cup.events << events(:banana_belt_1)
    assert_equal(1, or_cup.events.count, 'Events for new Oregon Cup')
    or_cup.events << events(:kings_valley)
    assert_equal(2, or_cup.events.count, 'Events for new Oregon Cup')
  end
  
  def test_recalculate
    # 2004
    # Banana Belt Pro/1/2
    # 1. Tonkin
    # 2. Weaver
    # 3. Matson
    # 16. Mollie
    
    # Kings Valley Pro 1/2 (2004, same as 2003)
    # 16. Tonkin (not fixture)
    # 17. Weaver (not fixture)
    # 20. Mollie (not fixture)
    # 21. Matson (not fixture)
    
    # Kings Valley women
    # 2. Alice
    # 15. Mollie
    
    # Oregon Cup
    # Men
    # 1. Tonkin     114
    # 2. Weaver      88
    # 3. Matson      60
    # 4. Mollie      15
    
    # Women
    # 1. Alice       75
    # 2. Mollie      15
    
    kings_valley_pro_1_2 = races(:kings_valley_pro_1_2_2004)
    matson = racers(:matson)
    tonkin = racers(:tonkin)
    weaver = racers(:weaver)
    mollie = racers(:mollie)
    kings_valley_pro_1_2.results.create(:racer => tonkin, :place => 16)
    kings_valley_pro_1_2.results.create(:racer => weaver, :place => 17)
    kings_valley_pro_1_2.results.create(:racer => mollie, :place => 20)
    kings_valley_pro_1_2.results.create(:racer => matson, :place => 21)
    
    category = Category.find_or_create_by_name('Senior Men')
    source_category = Category.find_or_create_by_name('Senior Men Pro 1/2')
    
    category = Category.find_or_create_by_name('Senior Women')
    source_category = Category.find_or_create_by_name('Senior Women 1/2/3')
    
    or_cup = OregonCup.create(:date => Date.new(2004))
    banana_belt_1 = events(:banana_belt_1)
    or_cup.events << banana_belt_1
    or_cup.events << events(:kings_valley_2004)
    assert(or_cup.errors.empty?, "Oregon Cup errors #{or_cup.errors.full_messages}")
    assert(banana_belt_1.errors.empty?, "banana_belt_1 errors #{or_cup.errors.full_messages}")
    assert_not_nil(banana_belt_1.oregon_cup_id, 'banana_belt_1.oregon_cup_id')

    assert_equal(1, OregonCup.count, "Oregon Cups before recalculate")
    OregonCup.recalculate(2004)
    assert_equal(1, OregonCup.count, "Oregon Cup events after recalculate")
    or_cup = OregonCup.find(:first, :conditions => ['date = ?', Date.new(2004)])
    assert_not_nil(or_cup, 'Should have Oregon Cup for 2004')
    assert_equal(1, or_cup.standings.count, "Oregon Cup standings after recalculate")
    assert_equal(2, or_cup.events.count, "Oregon Cup events after recalculate")
    results = 0
    for race in or_cup.standings.first.races
      results = results + race.results.size
    end
    assert_equal(6, results, "Oregon Cup results after recalculate")

    OregonCup.recalculate(2004)
    or_cup = OregonCup.find(:first, :conditions => ['date = ?', Date.new(2004)])
    assert_not_nil(or_cup, 'Should have Oregon Cup for 2004')
    assert_equal(1, OregonCup.count, "Oregon Cup events after recalculate")
    assert_equal(1, or_cup.standings.count, "Oregon Cup standings after recalculate")
    results = 0
    for race in or_cup.standings.first.races
      results = results + race.results.size
    end
    assert_equal(6, results, "Oregon Cup results after recalculate")
    
    or_cup.standings.first.races.sort_by {|s| s.name }
    races = or_cup.standings.first.races.sort_by {|s| s.name }

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

    assert_equal(racers(:mollie), races[0].results[3].racer, "Senior Men Oregon Cup results racer")
    assert_equal("4", races[0].results[3].place, "Mollie Oregon Cup results place")
    assert_equal(24, races[0].results[3].points, "Mollie Oregon Cup results points")
    assert_equal(2, races[0].results[3].scores.size, "Mollie Oregon Cup results scores")

    races[1].results.sort!
    assert_equal(racers(:alice), races[1].results[0].racer, "Senior Women Oregon Cup results racer")
    assert_equal("1", races[1].results[0].place, "Alice Oregon Cup results place")
    assert_equal(75, races[1].results[0].points, "Alice Oregon Cup results points")
    assert_equal(1, races[1].results[0].scores.size, "Alice Oregon Cup results scores")

    assert_equal(racers(:mollie), races[1].results[1].racer, "Senior Women Oregon Cup results racer")
    assert_equal("2", races[1].results[1].place, "Mollie Oregon Cup results place")
    assert_equal(15, races[1].results[1].points, "Mollie Oregon Cup results points")
    assert_equal(1, races[1].results[1].scores.size, "Mollie Oregon Cup results scores")
  end
  
  def test_latest_event_with_standings
    or_cup = OregonCup.new
    assert_nil(or_cup.latest_event_with_standings, 'Should have no event with standings')
    
    # Previous year
    or_cup = OregonCup.create(:date => Date.new(2004))
    or_cup.events << events(:banana_belt_1)
    or_cup.events << events(:kings_valley)

    or_cup = OregonCup.create!
    assert_nil(or_cup.latest_event_with_standings, 'Should have no event with standings')
    
    event = SingleDayEvent.create!
    standings = event.standings.create!(:event => event)
    race = standings.races.create!(:category => categories(:sr_p_1_2))
    race.results.create!(:place => '1', :racer => racers(:tonkin))
    or_cup = OregonCup.create!
    or_cup.events << event
    or_cup.events << SingleDayEvent.create!
    or_cup.events << SingleDayEvent.create!

    or_cup.reload
    assert_not_nil(or_cup.latest_event_with_standings, 'Should have event with standings')
    assert_equal(event, or_cup.latest_event_with_standings, 'Latest OR Cup event with standings')
  end
  
  def test_next_event
    or_cup = OregonCup.new
    assert(!or_cup.more_events?, 'More events')
    assert_nil(or_cup.next_event, 'Should have no next event')
    
    # Previous year
    or_cup = OregonCup.create(:date => Date.new(2004))
    or_cup.events << events(:banana_belt_1)
    or_cup.events << events(:kings_valley)
    or_cup.save!

    or_cup = OregonCup.new
    assert(!or_cup.more_events?, 'More events')
    assert_nil(or_cup.next_event, 'Should have no next_event')
    
    or_cup = OregonCup.create
    event = SingleDayEvent.new(:date => Date.today - 21)
    or_cup.events << event
    or_cup.reload
    assert(!or_cup.more_events?, 'More events')
    assert_nil(or_cup.next_event, 'Should have no next_event')

    event_2 = SingleDayEvent.new(:date => Date.today + 3)
    event_3 = SingleDayEvent.new(:date => Date.today + 30)
    or_cup.events << event_2
    or_cup.events << event_3
    or_cup.save!

    or_cup.reload
    assert(or_cup.more_events?, 'More events')
    assert_not_nil(or_cup.next_event, 'Should have next_event')
    assert_equal(event_2, or_cup.next_event, 'Next OR Cup event')
  end

end