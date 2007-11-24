require File.dirname(__FILE__) + '/../test_helper'

class StandingsTest < ActiveSupport::TestCase
  
  def test_new
    bb3 = events(:banana_belt_3)
    standings = bb3.standings.create
    assert(standings.races.empty?, "Standings should have empty races")
    assert_equal_dates(bb3.date, standings.date, "New standings should have event date")
    assert_equal_dates(bb3.name, standings.name, "race name")
  end
 
  def test_relationships
    banana_belt_1 = events(:banana_belt_1)
    standings = banana_belt_1.standings
    assert_equal(1, standings.size, "Banana Belt I standings")
    races = standings.first.races
    assert_equal(1, races.size, "Banana Belt I races")
    pro_1_2 = races.first
    assert_equal(4, pro_1_2.results.size, "Banana Belt I Pro 1/2 results")
  end
  
  def test_position
    bb3 = events(:banana_belt_3)
    standings_1 = bb3.standings.create(:event => bb3)
    standings_2 = bb3.standings.create(:event => bb3)
    standings_3 = bb3.standings.create(:event => bb3)
    
    assert_equal(1, standings_1.position, 'Standings 1 position')
    assert_equal(2, standings_2.position, 'Standings 2 position')
    assert_equal(3, standings_3.position, 'Standings 3 position')
    
    bb3.standings.sort!
    assert_equal(standings_1, bb3.standings[0], 'Standings 1')
    assert_equal(standings_2, bb3.standings[1], 'Standings 2')
    assert_equal(standings_3, bb3.standings[2], 'Standings 3')
    
    bb3.save!
    assert(!standings_1.new_record?, 'Standings 1 not new record?')
    assert(standings_1.first?, 'Standings 1 position')
    assert(!standings_2.first?, 'Standings 2 position')
    assert(!standings_2.last?, 'Standings 2 position')
    assert(standings_3.last?, 'Standings 3 position')
    
    bb3.standings.sort!
    assert(!standings_1.new_record?, 'Standings 1 not new record?')
    assert(standings_1.first?, 'Standings 1 position')
    assert(!standings_2.first?, 'Standings 2 position')
    assert(!standings_2.last?, 'Standings 2 position')
    assert(standings_3.last?, 'Standings 3 position')
  end
  
  def test_combined_tt
    jack_frost = events(:jack_frost_2002)
    assert_equal(1, jack_frost.standings.size, 'standings.size')
    categorized_standings = jack_frost.standings.first
    assert_equal(2, categorized_standings.races.size, 'races')
    assert_equal(3, categorized_standings.races.first.results.size + categorized_standings.races.last.results.size, 'total number of results')
    
    categorized_standings.create_or_destroy_combined_standings
    combined_standings = categorized_standings.combined_standings
    combined_standings.recalculate
    
    assert_equal(false, combined_standings.ironman, 'Ironman')
    
    assert_equal('Combined', combined_standings.name, 'name')
    assert_equal(0, combined_standings.bar_points, 'bar points')
    assert_equal(1, combined_standings.races.size, 'combined_standings.races')
    combined = combined_standings.races.first
    assert_equal(3, combined.results.size, 'combined.results')

    result = combined.results[0]
    assert_equal('1', result.place, 'place')
    assert_equal(racers(:molly), result.racer, 'racer')
    assert_equal(categories(:masters_35_plus_women), result.category, 'category')
    assert_equal('30:00.00', result.time_s, 'time_s')

    result = combined.results[1]
    assert_equal('2', result.place, 'place')
    assert_equal(racers(:weaver), result.racer, 'racer')
    assert_equal(categories(:sr_p_1_2), result.category, 'category')
    assert_equal('30:01.00', result.time_s, 'time_s')

    result = combined.results[2]
    assert_equal('3', result.place, 'place')
    assert_equal(racers(:alice), result.racer, 'racer')
    assert_equal(categories(:masters_35_plus_women), result.category, 'category')
    assert_equal('35:12.00', result.time_s, 'time_s')
  end
  
  def test_discipline
    event = SingleDayEvent.create
    standings = event.standings.create(:event => event)
    assert_nil(standings.discipline)
    
    event.discipline = 'Criterium'
    event.save!
    standings.reload
    assert_equal(event, standings.event, 'Standings event')
    assert_equal('Criterium', standings.event.discipline, 'Standings event discipline')
    assert_equal('Criterium', standings.discipline, 'Standings discipline should be same as parent if nil')
    
    standings.discipline = 'Road'
    standings.save!
    standings.reload
    assert_equal('Road', standings.discipline, 'Standings discipline')
  end
  
  def test_notes
    event = SingleDayEvent.create(:name => 'New Event')
    standings = event.standings.create
    assert_equal('', standings.notes, 'New notes')
    standings.notes = 'My notes'
    standings.save!
    standings.reload
    assert_equal('My notes', standings.notes)
  end

  def test_bar_points
    bb3 = events(:banana_belt_3)
    standings = Standings.new(:event => bb3)
    assert_equal(1, standings.bar_points, 'BAR points')

    assert_raise(ArgumentError, 'Fractional BAR points') {standings.bar_points = 0.5}
    assert_equal(1, standings.bar_points, 'BAR points')
    standings.save!
    standings.reload
    assert_equal(1, standings.bar_points, 'BAR points')

    standings = bb3.standings.create
    assert_equal(1, standings.bar_points, 'BAR points')
    standings.reload
    assert_equal(1, standings.bar_points, 'BAR points')

    standings = bb3.standings.build
    assert_equal(1, standings.bar_points, 'BAR points')
    standings.save!
    standings.reload
    assert_equal(1, standings.bar_points, 'BAR points')
  end

  def test_save_road
    event = SingleDayEvent.create!(:name => 'Woodlands', :discipline => 'Road')
    standings = event.standings.create
    assert_equal(1, event.standings.size, 'New road event standings should not create combined standings')
    
    RAILS_DEFAULT_LOGGER.debug('\n *** change discipline to Mountain Bike\n')
    standings.discipline = 'Mountain Bike'
    standings.save!
    assert_equal(2, event.standings(true).size, 'Change to MTB discipline should create combined standings')
    assert_equal('Mountain Bike', event.standings.first.discipline, 'standings discipline')
    assert_equal('Mountain Bike', event.standings.last.discipline, 'standings discipline')
    
    standings = event.standings.first
    standings.reload
    standings.combined_standings.reload
    RAILS_DEFAULT_LOGGER.debug('\n *** change discipline to Track\n')
    standings.discipline = 'Track'
    standings.save!
    assert_equal(1, event.standings(true).size, 'Change to Track discipline should remove combined standings')
  end

  def test_save_mtb
    event = SingleDayEvent.create!(:name => 'Reheers', :discipline => 'Mountain Bike')
    standings = event.standings.create
    event.reload
    assert_equal(2, event.standings.size, 'New MTB standings should create combined standings')
    
    standings.reload
    standings.destroy
    event.reload
    assert_equal(0, event.standings.size, 'MTB standings and combined standings should be deleted')
  end

  def test_races_with_results
    bb3 = events(:banana_belt_3)
    standings = bb3.standings.create
    assert(standings.races_with_results.empty?, 'No races')
    
    sr_p_1_2 = categories(:sr_p_1_2)
    standings.races.create(:category => sr_p_1_2)
    assert(standings.races_with_results.empty?, 'No results')
    
    senior_women = categories(:senior_women)
    race_1 = standings.races.create(:category => senior_women)
    race_1.results.create
    assert_equal([race_1], standings.races_with_results, 'One results')
    
    race_2 = standings.races.create(:category => sr_p_1_2)
    race_2.results.create
    women_4 = categories(:women_4)
    standings.races.create(:category => women_4)
    assert_equal([race_2, race_1], standings.races_with_results, 'Two races with results')
    
    standings.discipline = 'Time Trial'
    standings.save!
    combined_standings = standings.combined_standings
    assert_not_nil(combined_standings, 'Combined standings')
    assert_equal([race_2, race_1], standings.races_with_results, 'Two races with results')
    race_3 = combined_standings.races.first
    race_3.results.create
    assert(!race_3.results(true).empty?, 'Combined standings should have results')
    assert_equal([race_2, race_1, race_3], standings.races_with_results, 'Two races with results')
  end
  
  def test_full_name
    event = SingleDayEvent.create!(:name => 'Reheers', :discipline => 'Mountain Bike')
    standings = event.standings.create    
    assert_equal('Reheers', standings.full_name, 'full_name when standings name is nil')
    
    series = Series.create(:name => 'Bend TT Series')
    series_event = series.events.create(:name => 'Bend TT Series', :date => Date.new(2009, 4, 19))
    standings = series_event.standings.create    
    assert_equal('Bend TT Series', standings.full_name, 'full_name when series standings name is nil')
    
    series = Series.create(:name => 'Bend TT Series')
    series_event = series.events.create(:name => 'Bend TT Series', :date => Date.new(2009, 4, 19))
    standings = series_event.standings.create(:name => 'Bend TT Series')
    assert_equal('Bend TT Series', standings.full_name, 'full_name when series standings name is same as event')

    stage_race = events(:mt_hood)
    stage = stage_race.events.create(:name => stage_race.name)
    standings = stage.standings.create(:name => 'Cooper Spur Road Race')
    assert_equal('Mt. Hood Classic: Cooper Spur Road Race', standings.full_name, 'stage race standings full_name')

    stage_race = MultiDayEvent.create(:name => 'Cascade Classic')
    stage = stage_race.events.create(:name => 'Cascade Classic')
    standings = stage.standings.create(:name => 'Cascade Classic - Cascade Lakes Road Race')
    assert_equal('Cascade Classic - Cascade Lakes Road Race', standings.full_name, 'stage race standings full_name')
  end
end