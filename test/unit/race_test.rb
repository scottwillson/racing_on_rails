require File.dirname(__FILE__) + '/../test_helper'

class RaceTest < Test::Unit::TestCase
  
  def test_new_from_hash
    race = Race.new({
      :standings => Standings.new(:event => events(:pir_2)),
      :category_name => "Masters 35+ Women"
    })
    assert_equal("Masters 35+ Women", race.name, "race name")
  end
  
  def test_save_existing_category
    race = Race.new({
      :standings => Standings.new(:event => events(:pir_2)),
      :category_name => "Masters 35+ Women"
    })
    race.find_associated_records
    race.save!    
  end
  
  def test_result_columns
    event = SingleDayEvent.create
    standings = Standings.create(:event => event)
    race = Race.create(:category_name => "Masters Women", :standings => standings)
    assert_equal(Race::DEFAULT_RESULT_COLUMNS, race.result_columns_or_default, "race result_columns")
    race.save!
    race.reload
    assert_equal(Race::DEFAULT_RESULT_COLUMNS, race.result_columns_or_default, "race result_columns after save")

    result_columns = ["place", "name", "category"]
    race.result_columns = result_columns
    race.save!
    race.reload
    assert_equal(result_columns, race.result_columns_or_default, "race result_columns after save")

    event = SingleDayEvent.create
    standings = Standings.create(:event => event)
    race = Race.create(:category_name => "Masters Women 50+", :standings => standings, :result_columns => result_columns)
    assert_equal(result_columns, race.result_columns_or_default, "race result_columns")
    race.save!
    race.reload
    assert_equal(result_columns, race.result_columns_or_default, "race result_columns after save")
  end
  
  def test_invalid_result_column
    event = SingleDayEvent.create
    standings = Standings.create(:event => event)
    race = Race.create(:category_name => "Masters Women", :standings => standings)

    race.result_columns = ["place", "name", "hometown", "category"]
    race.save
    assert(!race.valid?, 'Race with bogus result column should be invalid')
  end
  
  def test_bar_points
    race = races(:jack_frost_pro_1_2)
    assert_nil(race[:bar_points], 'BAR points column value')
    assert_equal(1, race.bar_points, 'BAR points')
    
    race.bar_points = 1
    race.save!
    race.reload
    assert_nil(race[:bar_points], 'BAR points column value')
    assert_equal(1, race.bar_points, 'BAR points')
    
    race.bar_points = 0
    race.save!
    race.reload
    assert_equal(0, race[:bar_points], 'BAR points column value')
    assert_equal(0, race.bar_points, 'BAR points')
    
    race.standings.bar_points = 2
    race.standings.save!
    race.reload
    assert_equal(0, race[:bar_points], 'BAR points column value')
    assert_equal(0, race.bar_points, 'BAR points')

    race.bar_points = nil
    race.save!
    race.reload
    assert_nil(race[:bar_points], 'BAR points column value')
    assert_equal(2, race.bar_points, 'BAR points')
  end
  
  def test_bar_points
    event = SingleDayEvent.create
    standings = Standings.create(:event => event)
    race = Race.create(:category_name => "Masters Women", :standings => standings)
    assert_equal(1, race.bar_points, 'BAR points')

    assert_raise(ArgumentError, 'Fractional BAR points') {race.bar_points = 0.3333}
    assert_equal(1, race.bar_points, 'BAR points')
    race.save!
    race.reload
    assert_equal(1, race.bar_points, 'BAR points')
  end

  def test_notes
    event = SingleDayEvent.create(:name => 'New Event')
    standings = event.standings.create
    race = standings.races.create(:category => categories(:sr_p_1_2))
    assert_equal('', race.notes, 'New notes')
    race.notes = 'My notes'
    race.save!
    race.reload
    assert_equal('My notes', race.notes)
  end
  
  # Return value from field_size column. If column is blank, count results
  def test_field_size
    single_speed = Category.create(:name => "Singlespeed")
    race = standings(:kings_valley_2004).races.create(:category => single_speed)
    assert_equal(0, race.field_size, 'New race field size')
    
    race = races(:banana_belt_pro_1_2)
    assert_equal(4, race.field_size, 'Race field size with empty field_size column')
    
    race.field_size = 120
    race.save!
    assert_equal(120, race.field_size, 'Race field size from field_size column')
  end
  
  def test_place_results_by_points
    race = standings(:jack_frost).races.create(:category_name => "Masters Men 50+")
    race.place_results_by_points
    
    first_result = race.results.create
    second_result = race.results.create
    
    race.results(true)
    race.place_results_by_points
    race.results(true)
    assert_equal(first_result, race.results.first, 'First result')
    assert_equal('1', race.results.first.place, 'First result place')
    assert_equal(second_result, race.results.last, 'Last result')
    assert_equal('1', race.results.last.place, 'Last result place')
    
    race = standings(:jack_frost).races.create(:category_name => "Masters Men 60+")
    results = [
      race.results.create(:points => 90, :place => 4),
      race.results.create(:points => 0, :place => 5),
      race.results.create(:points => 89, :place => 4),
      race.results.create(:points => 89, :place => ''),
      race.results.create(:points => 100, :place => 1),
      race.results.create(:points => 89)
    ]
    
    race.results(true)
    race.place_results_by_points
    race.results(true).sort!
    
    assert_equal(results[4], race.results[0], 'Result 0')
    assert_equal('1', race.results[0].place, 'Result 0 place')
    assert_equal(100, race.results[0].points, 'Result 0 points')
    
    assert_equal(results[0], race.results[1], 'Result 1')
    assert_equal('2', race.results[1].place, 'Result 1 place')
    assert_equal(90, race.results[1].points, 'Result 1 points')
    
    assert_equal('3', race.results[2].place, 'Result 2 place')
    assert_equal(89, race.results[2].points, 'Result 2 points')
    
    assert_equal('3', race.results[3].place, 'Result 3 place')
    assert_equal(89, race.results[3].points, 'Result 3 points')
    
    assert_equal('3', race.results[4].place, 'Result 4 place')
    assert_equal(89, race.results[4].points, 'Result 4 points')
    
    assert_equal(results[1], race.results[5], 'Result 5')
    assert_equal('6', race.results[5].place, 'Result 5 place')
    assert_equal(0, race.results[5].points, 'Result 5 points')
  end
  
  # Look at source results for tie-breaking
  # Intentional nonsene in some results and points to test sorting
  def test_competition_place_results_by_points
    race = standings(:jack_frost).races.create(:category_name => "Masters Men 50+")

    20.times do
      race.results.create
    end
    
    ironman = Ironman.create(:date => Date.today)
    ironman_race = ironman.standings.create(:name => '2006').races.create(:category => Category.new(:name => 'Ironman'))
    
    first_competition_result = ironman_race.results.create
    first_competition_result.scores.create(:source_result => race.results[0], :competition_result => first_competition_result, :points => 45)
    
    second_competition_result = ironman_race.results.create
    second_competition_result.scores.create(:source_result => race.results[2], :competition_result => second_competition_result, :points => 45)
    
    third_competition_result = ironman_race.results.create
    race.results[3].place = 2
    race.results[3].save!
    third_competition_result.scores.create(:source_result => race.results[3], :competition_result => third_competition_result, :points => 15)
    third_competition_result.scores.create(:source_result => race.results[4], :competition_result => third_competition_result, :points => 15)
    race.results[4].place = 3
    race.results[4].save!
    
    fourth_competition_result = ironman_race.results.create
    fourth_competition_result.scores.create(:source_result => race.results[1], :competition_result => fourth_competition_result, :points => 30)
    race.results[1].place = 1
    race.results[1].save!
    
    fifth_competition_result = ironman_race.results.create
    fifth_competition_result.scores.create(:source_result => race.results[5], :competition_result => fifth_competition_result, :points => 4)
    race.results[5].place = 15
    race.results[5].save!
    fifth_competition_result.scores.create(:source_result => race.results[7], :competition_result => fifth_competition_result, :points => 2)
    race.results[7].place = 17
    race.results[7].save!
    
    sixth_competition_result = ironman_race.results.create
    sixth_competition_result.scores.create(:source_result => race.results[6], :competition_result => sixth_competition_result, :points => 5)
    race.results[6].place = 15
    race.results[6].save!
    sixth_competition_result.scores.create(:source_result => race.results[8], :competition_result => sixth_competition_result, :points => 1)
    race.results[8].place = 18
    race.results[8].save!
    
    seventh_competition_result = ironman_race.results.create
    seventh_competition_result.scores.create(:source_result => race.results[11], :competition_result => seventh_competition_result, :points => 2)
    race.results[11].place = 20
    race.results[11].save!
    
    eighth_competition_result = ironman_race.results.create
    eighth_competition_result.scores.create(:source_result => race.results[10], :competition_result => eighth_competition_result, :points => 1)
    race.results[10].place = 20
    race.results[10].save!
    eighth_competition_result.scores.create(:source_result => race.results[9], :competition_result => eighth_competition_result, :points => 1)
    race.results[9].place = 25
    race.results[9].save!
    
    ironman_race.results(true)
    for result in ironman_race.results
      result.calculate_points
      result.save!
    end
    ironman_race.place_results_by_points
    ironman_race.results(true).sort!
    assert_equal(first_competition_result, ironman_race.results.first, 'First result')
    assert_equal('1', ironman_race.results.first.place, 'First result place')
    assert_equal(second_competition_result, ironman_race.results[1], 'Second result')
    assert_equal('1', ironman_race.results[1].place, 'Second result place')
    assert_equal(fourth_competition_result, ironman_race.results[2], 'Third result')
    assert_equal('3', ironman_race.results[2].place, 'Third result place')
    assert_equal(third_competition_result, ironman_race.results[3], 'Fourth result')
    assert_equal('4', ironman_race.results[3].place, 'Fourth result place')
    assert_equal(fifth_competition_result, ironman_race.results[4], 'Fifth result')
    assert_equal('5', ironman_race.results[4].place, 'Fifth result place')
    assert_equal(sixth_competition_result, ironman_race.results[5], 'Sixth result')
    assert_equal('6', ironman_race.results[5].place, 'Sixth result place')
    assert_equal(eighth_competition_result, ironman_race.results[6], '7th result')
    assert_equal('7', ironman_race.results[6].place, '7th result place')
    assert_equal(seventh_competition_result, ironman_race.results[7], '8th result')
    assert_equal('8', ironman_race.results[7].place, '8th result place')
  end
  
  def test_calculate_members_only_places!
    standings = standings(:banana_belt)
    race = standings.races.create(:category => categories(:senior_men))
    race.calculate_members_only_places!
    
    race = standings.races.create(:category => categories(:senior_women))
    non_members = []
    for i in 0..2
      non_members << Racer.create(:name => "Non member #{i}", :member => false)
      assert(!non_members[i].member?, 'Should not be a member')
    end
    
    race.results.create(:place => '1', :racer => non_members[0])
    race.results.create(:place => '2', :racer => racers(:weaver))
    race.results.create(:place => '3', :racer => non_members[1])
    race.results.create(:place => '4', :racer => racers(:molly))
    race.results.create(:place => '5', :racer => non_members[2])
    
    race.reload.results(true)
    race.calculate_members_only_places!
    assert_equal('1', race.results[0].place, 'Result 0 place')
    assert_equal('', race.results[0].members_only_place, 'Result 0 place')
    assert_equal(non_members[0], race.results[0].racer, 'Result 0 racer')
    
    assert_equal('2', race.results[1].place, 'Result 1 place')    
    assert_equal('1', race.results[1].members_only_place, 'Result 1 place')
    assert_equal(racers(:weaver), race.results[1].racer, 'Result 1 racer')
    
    assert_equal('3', race.results[2].place, 'Result 2 place')    
    assert_equal('', race.results[2].members_only_place, 'Result 2 place')
    assert_equal(non_members[1], race.results[2].racer, 'Result 2 racer')
    
    assert_equal('4', race.results[3].place, 'Result 3 place')
    assert_equal('2', race.results[3].members_only_place, 'Result 3 place')
    assert_equal(racers(:molly), race.results[3].racer, 'Result 3 racer')
    
    assert_equal('5', race.results[4].place, 'Result 4 place')    
    assert_equal('', race.results[4].members_only_place, 'Result 4 place')
    assert_equal(non_members[2], race.results[4].racer, 'Result 4 racer')
  end
  
  def test_dates_of_birth
    event = SingleDayEvent.create!(:date => Date.today)
    standings = event.standings.create!
    race = standings.races.create!(:category => categories(:senior_men))
    assert_equal_dates(Date.new(Date.today.year - 999, 1, 1), race.dates_of_birth.begin, 'race.dates_of_birth.begin')
    assert_equal_dates(Date.new(Date.today.year, 12, 31), race.dates_of_birth.end, 'race.dates_of_birth.end')
    
    event = SingleDayEvent.create!(:date => Date.new(2000, 9, 8))
    standings = event.standings.create!
    race = standings.races.create!(:category => Category.new(:name =>'Espoirs', :ages => 18..23))
    assert_equal_dates(Date.new(1977, 1, 1), race.dates_of_birth.begin, 'race.dates_of_birth.begin')
    assert_equal_dates(Date.new(1982, 12, 31), race.dates_of_birth.end, 'race.dates_of_birth.end')
  end
end