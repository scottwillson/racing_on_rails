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
    race = standings(:kings_valley_2004).races.create!(:category => single_speed)
    assert_equal(0, race.field_size, 'New race field size')
    
    race = races(:banana_belt_pro_1_2)
    assert_equal(4, race.field_size, 'Race field size with empty field_size column')
    
    race.field_size = 120
    race.save!
    assert_equal(120, race.field_size, 'Race field size from field_size column')
  end
  
  def test_place_results_by_points
    race = standings(:jack_frost).races.create!(:category_name => "Masters Men 50+")
    race.place_results_by_points
    
    first_result = race.results.create!
    second_result = race.results.create!
    
    race.results(true)
    race.place_results_by_points
    race.results(true)
    assert_equal(first_result, race.results.first, 'First result')
    assert_equal('1', race.results.first.place, 'First result place')
    assert_equal(second_result, race.results.last, 'Last result')
    assert_equal('1', race.results.last.place, 'Last result place')
    
    race = standings(:jack_frost).races.create!(:category_name => "Masters Men 60+")
    results = [
      race.results.create!(:points => 90, :place => 4),
      race.results.create!(:points => 0, :place => 5),
      race.results.create!(:points => 89, :place => 4),
      race.results.create!(:points => 89, :place => ''),
      race.results.create!(:points => 100, :place => 1),
      race.results.create!(:points => 89)
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
end