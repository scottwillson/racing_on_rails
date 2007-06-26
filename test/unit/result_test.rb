require File.dirname(__FILE__) + '/../test_helper'

class ResultTest < Test::Unit::TestCase

  def setup
    # Discipline class may have loaded earlier with no aliases in database
    Discipline.load_aliases
  end

  def test_racer_first_last_name
    result = Result.new
    assert_equal("", result.first_name, "Racer first name w/nil racer")
    assert_equal("", result.last_name, "Racer last name w/nil racer")
    assert_equal("", result.team_name, "Racer team name w/nil racer")
  end
  
  def test_name
    result = Result.new
    assert_equal("", result.name, "Racer name w/nil racer")
    
    result = Result.new(:racer => racers(:weaver))
    assert_equal("Ryan Weaver", result.name, "Racer name")
    
    racer = Racer.new(:last_name => 'Willson')
    result = Result.new(:racer => racer)
    assert_equal("Willson", result.name, "Racer name")
    
    racer = Racer.new(:first_name => 'Clara')
    result = Result.new(:racer => racer)
    assert_equal("Clara", result.name, "Racer name")

    result = Result.new
    assert_equal("", result.name, "Racer name")
    result.name = 'Clara Hughes'
    assert_equal("Clara Hughes", result.name, "Racer name")
    assert_equal("Clara", result.first_name, "Racer first_name")
    assert_equal("Hughes", result.last_name, "Racer last_name")

    result = Result.new
    result.name = 'Walrod, Marjon'
    assert_equal("Marjon Walrod", result.name, "Racer name")
    assert_equal("Marjon", result.first_name, "Racer first_name")
    assert_equal("Walrod", result.last_name, "Racer last_name")
  end

  def test_save
    event = SingleDayEvent.new(:name => "Tabor CR", :discipline => 'Road')
    event.save!
    standings = Standings.new(:event => event)
    standings.save!
    category = Category.find_by_name("Senior Men Pro 1/2")
    race = Race.new(:standings => standings, :category => category)
    race.save!
    assert_equal(0, race.results.size, "Results before save")
    assert_nil(Racer.find_by_last_name("Hampsten"), "Hampsten should not be in DB")
    assert_nil(Team.find_by_name("7-11"), "7-11 should not be in DB")
    
    racer = Racer.new(:last_name => "Hampsten")
    result = race.results.build
    result.racer = racer    
    result.place = "17"
    result.number = "H67"
    team = Team.new(:name => "7-11")
    result.team = team

    race.save!

    assert_equal(1, race.results.size, "Results after save")
    result_from_db = race.results.first
    racer_from_db = Racer.find_by_last_name("Hampsten")
    assert_not_nil(racer_from_db, "Hampsten should  be  DB")
    assert_equal(result.racer, result_from_db.racer, "result.racer")
    assert_not_nil(Team.find_by_name("7-11"), "7-11 should be in DB")
    assert_equal(result.team, result_from_db.team, "result.team")
    assert_equal("17", result_from_db.place, "result.place")
    assert_equal("H67", result_from_db.number, "result.number")
    assert(!result_from_db.new_record?, "result_from_db.new_record")
    assert(!result.team.new_record?, "team.new_record")
    assert(!racer_from_db.new_record?, "racer_from_db.new_record")
  end

  def test_new_with_nested_attributes
    attributes = {:place => "22", :last_name => "Ulrich"}
    result = Result.new(attributes)
    assert_equal("Ulrich", result.racer.last_name, "racer.last_name")
    attributes = {:place => "DNS", :last_name => "Vinokurov"}
    result = Result.new(attributes)
    assert_equal("Vinokurov", result.racer.last_name, "racer.last_name")
    assert_equal("DNS", result.place, "place")
  end
  
  def test_find_associated_records
    event = SingleDayEvent.new(:name => "Tabor CR")
    standings = Standings.new(:event => event)
    category = Category.find_by_name("Senior Men Pro 1/2")
    race = Race.new(:standings => standings, :category => category)
    result1 = race.results.build(
      :first_name => "Tom", :last_name => "Boonen", :team_name => "Davitamon"
    )
    result2 = race.results.build(
      :first_name => "Paulo", :last_name => "Bettini", :team_name => "Davitamon"
    )
    RACING_ON_RAILS_DEFAULT_LOGGER.debug("Result.transaction")
    Result.transaction do
      event.save!
      standings.save!
      race.save!
    end
    assert(!result1.team.new_record?, "First result team should be saved")
    assert(!result2.team.new_record?, "Second result team should be saved")
    assert_equal(result1.team.id, result2.team.id, "Teams should have same ID")
  end

  def test_first_name
    attributes = {:place => "22", :first_name => "Jan"}
    result = Result.new(attributes)
    assert_equal("Jan", result.first_name, "racer.first_name")
    assert_equal("Jan", result.racer.first_name, "racer.first_name")
    
    result.first_name = "Ivan"
    assert_equal("Ivan", result.first_name, "racer.first_name")
    assert_equal("Ivan", result.racer.first_name, "racer.first_name")
  end

  def test_last_name
    attributes = {:place => "22", :last_name => "Ulrich"}
    result = Result.new(attributes)
    assert_equal("Ulrich", result.last_name, "racer.last_name")
    assert_equal("Ulrich", result.racer.last_name, "racer.last_name")
    
    result.last_name = "Basso"
    assert_equal("Basso", result.last_name, "racer.last_name")
    assert_equal("Basso", result.racer.last_name, "racer.last_name")
  end

  def test_team_name
    attributes = {:place => "22", :team_name => "T-Mobile"}
    result = Result.new(attributes)
    assert_equal("T-Mobile", result.team_name, "racer.team_name")
    assert_equal("T-Mobile", result.team.name, "racer.team")
    
    result.team_name = "CSC"
    assert_equal("CSC", result.team_name, "racer.team_name")
    assert_equal("CSC", result.team.name, "racer.team")
  end
  
  def test_category_name
    attributes = {:place => "22", :last_name => "Ulrich"}
    result = Result.new(attributes)
    assert_equal("", result.category_name, "category_name")
    
    result.category = Category.find_by_name("Senior Men Pro 1/2")
    assert_equal("Senior Men Pro 1/2", result.category_name, "category_name")

    result = Result.new
    result.category_name = "Senior Men Pro 1/2"
    assert_equal("Senior Men Pro 1/2", result.category_name, "category_name")

    result.category_name = ""
    assert_equal("", result.category_name, "category_name")

    result.category_name = nil
    assert_equal('', result.category_name, "category_name")
  end

  def test_racer_team
    standings = standings(:kings_valley_2004)
    race = standings.races.create(:category => categories(:cx_a))
    result = race.results.build(:place => '3', :number => '932')
    racer = Racer.new(:last_name => 'Kovach', :first_name => 'Barry')
    team = Team.new(:name => 'Sorella Forte ')
    result.racer = racer
    result.team = team

    result.save!
    assert(!racer.new_record?, 'racer new record')
    assert(!team.new_record?, 'team new record')
    assert_equal(team, result.team, 'result team')
    assert_equal(nil, racer.team, 'result team')
    sorella_forte = Team.find_by_name('Sorella Forte')
    assert_equal(sorella_forte, result.team, 'result team')
    assert_equal(nil, racer.team, 'result team')

    race = standings.races.create(:category => categories(:senior_women))
    result = race.results.build(:place => '3', :number => '932')
    result.racer = racer
    new_team = Team.new(:name => 'Bike Gallery')
    result.racer = racer
    result.team = new_team

    result.save!
    bike_gallery_from_db = Team.find_by_name('Bike Gallery')
    assert_equal(bike_gallery_from_db, result.team, 'result team')
    assert_equal(nil, racer.team, 'result team')
    assert_not_equal(bike_gallery_from_db, racer.team, 'result team')
    
    racer_with_no_team = Racer.create(:last_name => 'Ollerenshaw', :first_name => 'Doug')
    result = race.results.build(:place => '3', :number => '932')
    result.racer = racer_with_no_team
    vanilla = teams(:vanilla)
    result.team = vanilla

    result.save!
    assert_equal(vanilla, result.team, 'result team')
    assert_equal(nil, racer_with_no_team.team, 'result team')
  end
  
  def test_event
    result = races(:kings_valley_pro_1_2_2004).results.create(:place => 1, :first_name => 'Clara', :last_name => 'Willson', :number => '300')
    result.reload
    assert_equal(events(:kings_valley_2004), result.event, 'Result event')
  end
  
  def test_time_s
    result = Result.new
    assert_in_delta(0.0, result.time, 0.0001, "no time")
    assert_equal('', result.time_s, 'no time_s')
    result.time_s = ''
    assert_in_delta(0.0, result.time, 0.0001, "no time")
    
    result.time = 2597.0
    assert_in_delta(2597.0, result.time, 0.0001, "time")
    assert_equal('43:17.00', result.time_s, 'time_s')
    result.time_s = '43:17.00'
    assert_in_delta(2597.0, result.time, 0.0001, "time")
    
    result.time_s = '30:00'
    assert_in_delta(1800.0, result.time, 0.0001, "time")
    assert_equal('30:00.00', result.time_s, 'time_s')
    result.time_s = '30:00'
    assert_in_delta(1800.0, result.time, 0.0001, "time")
    
    result.time = 3609.0
    assert_in_delta(3609.0, result.time, 0.0001, "time")
    assert_equal('01:00:09.00', result.time_s, 'time_s')
    result.time_s = '01:00:09'
    assert_in_delta(3609.0, result.time, 0.0001, "time")
    
    result.time_s = '1:59:59'
    assert_in_delta(7199.0, result.time, 0.0001, "time")
    assert_equal('01:59:59.00', result.time_s, 'time_s')
    result.time_s = '01:59:59'
    assert_in_delta(7199.0, result.time, 0.0001, "time")

    result.time = 2252.0
    assert_in_delta(2252.0, result.time, 0.0001, "time")
    assert_equal('37:32.00', result.time_s, 'time_s')
    result.time_s = '37:32'
    assert_in_delta(2252.0, result.time, 0.0001, "time")

    result.time = 2449.0
    assert_in_delta(2449.0, result.time, 0.0001, "time")
    assert_equal('40:49.00', result.time_s, 'time_s')
    result.time_s = '40:49'
    assert_in_delta(2449.0, result.time, 0.0001, "time")

    result.time = 1530.29
    assert_in_delta(1530.29, result.time, 0.0001, "time")
    assert_equal('25:30.29', result.time_s, 'time_s')
    result.time_s = '25:30.29'
    assert_in_delta(1530.29, result.time, 0.0001, "time")

    result.time = 1567.98
    assert_in_delta(1567.98, result.time, 0.0001, "time")
    assert_equal('26:07.98', result.time_s, 'time_s')
    result.time_s = '26:07.98'
    assert_in_delta(1567.98, result.time, 0.0001, "time")
    
    # Other times
    result.time_bonus_penalty = 10.0
    assert_in_delta(10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    assert_equal('00:10.00', result.time_bonus_penalty_s, 'time_bonus_penalty_s')
    result.time_bonus_penalty_s = '0:00:10'
    assert_in_delta(10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")

    result.time_bonus_penalty = 90.0
    assert_in_delta(90.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    assert_equal('01:30.00', result.time_bonus_penalty_s, 'time_bonus_penalty_s')
    result.time_bonus_penalty_s = '0:01:30'
    assert_in_delta(90.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")

    result.time_total = 12798.0
    assert_in_delta(12798.0, result.time_total, 0.0001, "time_total")
    assert_equal('03:33:18.00', result.time_total_s, 'time_total_s')
    result.time_total_s = '3:33:18.00'
    assert_in_delta(12798.0, result.time_total, 0.0001, "time_total")

    result.time_gap_to_leader = 74.0
    assert_in_delta(74.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")
    assert_equal('01:14.00', result.time_gap_to_leader_s, 'time_gap_to_leader_s')
    result.time_gap_to_leader_s = '0:01:14'
    assert_in_delta(74.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")

    # FIXME: Make these tests pass!
#     result.time_gap_to_leader = 0.0
#     assert_in_delta(0.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")
#     assert_equal('0:00:00', result.time_gap_to_leader_s, 'time_gap_to_leader_s')
#     result.time_gap_to_leader_s = '0:00:00'
#     assert_in_delta(0.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")
# 
#     result.time_bonus_penalty = -10.0
#     assert_in_delta(-10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
#     assert_equal('-0:00:10', result.time_bonus_penalty_s, 'time_bonus_penalty_s')
#     result.time_bonus_penalty_s = '-0:00:10'
#     assert_in_delta(-10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
  end

  def test_sort
    results = [
     Result.new(:place => '1'),
     Result.new(:place => ''),
     Result.new(:place => nil),
     Result.new(:place => '11'),
     Result.new(:place => 'DNS'),
     Result.new(:place => '3'),
     Result.new(:place => 'DNF'),
     Result.new(:place => '')
    ]
    
    results.sort!
    assert_equal('1', results[0].place, 'result 0 place')
    assert_equal('3', results[1].place, 'result 1 place')
    assert_equal('11', results[2].place, 'result 2 place')
    assert_equal('DNF', results[3].place, 'result 3 place')
    assert_equal('DNS', results[4].place, 'result 4 place')
    assert(results[5].place.blank?, 'result 5 place blank')
    assert(results[6].place.blank?, 'result 6 place blank')

    results = [
     Result.new(:place => '1'),
     Result.new(:place => '2'),
     Result.new(:place => '11'),
     Result.new(:place => 'DNF'),
     Result.new(:place => ''),
     Result.new(:place => nil)
    ]
    
    results.sort!
    assert_equal('1', results[0].place, 'result 0 place')
    assert_equal('2', results[1].place, 'result 1 place')
    assert_equal('11', results[2].place, 'result 2 place')
    assert_equal('DNF', results[3].place, 'result 3 place')
    assert(results[4].place.blank?, 'result 4 place blank')
    assert(results[5].place.blank?, 'result 5 place blank')

    results = [
     Result.new(:place => '1'),
     Result.new(:place => '2'),
     Result.new(:place => '11'),
     Result.new(:place => 'DQ'),
     Result.new(:place => 'DNF'),
     Result.new(:place => nil)
    ]
    
    results.sort!
    assert_equal('1', results[0].place, 'result 0 place')
    assert_equal('2', results[1].place, 'result 1 place')
    assert_equal('11', results[2].place, 'result 2 place')
    assert_equal('DNF', results[3].place, 'result 4 place')
    assert_equal('DQ', results[4].place, 'result 3 place')
    assert(results[5].place.blank?, 'result 5 place blank')

    result_5 = Result.new(:place => '5')
    result_dnf = Result.new(:place => 'DNF')
    result_5 <=> result_dnf
    result_dnf <=> result_5
    
    result_5 = Result.new(:place => 5)
    result_5 <=> result_dnf
    result_dnf <=> result_5
  end

  def test_find_by_alias
    Alias.create(:team => teams(:kona), :name => 'Kona Les Gets')
    Alias.create(:racer => racers(:tonkin), :name => 'Erin Tonkin')
  
    # new, no aliases
    race = races(:kings_valley_pro_1_2_2004)
    result = race.results.create(:place => 1, :first_name => 'Fausto', :last_name => 'Coppi', :team_name => 'Bianchi', :number => '')
    assert_equal('Fausto Coppi', result.name, 'racer name')
    assert_equal('Bianchi', result.team_name, 'team name')
    
    # existing racer, new team
    result = race.results.create(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Bianchi', :number => '')
    result.save!
    assert_equal(racers(:tonkin).id, result.racer.id, 'racer id')
    assert_equal('Erik Tonkin', result.name, 'racer name')
    assert_equal('Bianchi', result.team_name, 'team name')
    
    # new racer, existing team
    result = race.results.create(:place => 1, :first_name => 'Fausto', :last_name => 'Coppi', :team_name => 'Kona', :number => '')
    result.save!
    assert_equal(teams(:kona).id, result.team.id, 'team id')
    assert_equal('Fausto Coppi', result.name, 'racer name')
    assert_equal('Kona', result.team_name, 'team name')
    
    # existing racer, existing team
    result = race.results.create(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'racer name')
    assert_equal('Kona', result.team_name, 'team name')

    # new racer, aliased team
    result = race.results.create(:place => 1, :first_name => 'Fausto', :last_name => 'Coppi', :team_name => 'Kona Les Gets', :number => '')
    result.save!
    assert_equal('Fausto Coppi', result.name, 'racer name')
    assert_equal('Kona', result.team_name, 'team name')
    
    # aliased racer, new team
    result = race.results.create(:place => 1, :first_name => 'Erin', :last_name => 'Tonkin', :team_name => 'Bianchi', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'racer name')
    assert_equal('Bianchi', result.team_name, 'team name')
    
    # aliased racer, aliased team
    result = race.results.create(:place => 1, :first_name => 'Erin', :last_name => 'Tonkin', :team_name => 'Kona Les Gets', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'racer name')
    assert_equal('Kona', result.team_name, 'team name')
    
    # aliased racer, existing team
    result = race.results.create(:place => 1, :first_name => 'Erin', :last_name => 'Tonkin', :team_name => 'Kona', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'racer name')
    assert_equal('Kona', result.team_name, 'team name')
    
    # existing racer, aliased team
    result = race.results.create(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona Les Gets', :number => '')
    result.save!
    assert_equal('Erik Tonkin', result.name, 'racer name')
    assert_equal('Kona', result.team_name, 'team name')
    
    # no racer, no team
    result = race.results.create(:place => 1, :number => '')
    result.save!
    assert_equal('', result.name, 'racer name')
    assert_equal('', result.team_name, 'team name')
  end
  
  def test_save_number
    results = races(:kings_valley_pro_1_2_2004).results
    result = results.create(:place => 1, :first_name => 'Clara', :last_name => 'Willson', :number => '300')
    assert(result.racer.errors.empty?, "Racers should have no errors, but had: #{result.racer.errors.full_messages}")
    assert_nil(result.racer(true).road_number(true), 'Current road number')
    road_number_2004 = result.racer.race_numbers.detect{|number| number.year == 2004}
    assert_not_nil(road_number_2004.value, '2004 road number')
    assert_equal('300', road_number_2004.value, '2004 road number')
    assert(result.racer.ccx_number.blank?, 'Cyclocross number')
    assert(result.racer.xc_number.blank?, 'MTB number')
  end
  
  def test_find_associated_records
    # Same name, number as existing racer
    tonkin = racers(:tonkin)
    results = races(:kings_valley_pro_1_2_2004).results
    result_1 = results.create(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :number => '104')
    assert_equal(tonkin, result_1.racer, 'Racer')
    
    # Same name, different number as existing racer
    tonkin = racers(:tonkin)
    results = races(:kings_valley_pro_1_2_2004).results
    result_2 = results.create(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :number => '4100')
    assert_equal(tonkin, result_2.racer, 'Racer')
    # TODO assert warning
    
    # Different name, same number as existing racer
    # TODO Should be warning with possibility to create alias
    tonkin = racers(:tonkin)
    results = races(:kings_valley_pro_1_2_2004).results
    result_3 = results.create(:place => 1, :first_name => 'Ron', :last_name => 'Tonkin', :number => '104')
    assert_not_equal(tonkin, result_3.racer, 'Racer')
    assert_equal("Ron", result_3.racer.first_name, 'Racer')

    # Clean up from previous
    result_1.destroy
    result_2.destroy
    result_3.destroy
    Racer.destroy_all(['first_name<>? and last_name=?', 'erik', 'tonkin'])
    assert_equal(1, Racer.find_all_by_first_name_and_last_name('Erik','Tonkin').size, 'Erik Tonkins in database')

    # CX: Same name, different number as existing racer
    tonkin = racers(:tonkin)
    tonkin.ccx_number = '555A'
    tonkin.save!
    kings_valley_2004 = events(:kings_valley_2004)
    kings_valley_2004.discipline = 'Cyclocross'
    kings_valley_2004.save!
    results = races(:kings_valley_pro_1_2_2004).results
    result = results.create(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin', :number => '999')
    assert_equal(tonkin, result.racer, 'Racer')
    # TODO assert wrong number warning
    
    # MTB: Same name as alias for existing racer, different number as existing racer
    tonkin = racers(:tonkin)
    tonkin.xc_number = '70A'
    tonkin.save!
    kings_valley_2004 = events(:kings_valley_2004)
    kings_valley_2004.discipline = 'Mountain Bike'
    kings_valley_2004.save!
    results = races(:kings_valley_pro_1_2_2004).results
    result = results.create(:place => 1, :first_name => 'Eric', :last_name => 'Tonkin', :number => '999')
    assert_equal(tonkin, result.racer, 'Racer')
    # TODO assert wrong number warning
    
    # MTB: Same name as alias for existing racer, same number as existing racer
    tonkin = racers(:tonkin)
    kings_valley_2004 = events(:kings_valley_2004)
    kings_valley_2004.discipline = 'Mountain Bike'
    kings_valley_2004.save!
    results = races(:kings_valley_pro_1_2_2004).results
    result = results.create(:place => 1, :first_name => 'Eric', :last_name => 'Tonkin', :number => '70A')
    assert_equal(tonkin, result.racer, 'Racer')
  end
  
  def test_find_racers
    # TODO Add warning that numbers don't match
    tonkin = racers(:tonkin)
    race = races(:banana_belt_pro_1_2)
    event = events(:banana_belt_1)
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin')
    assert_equal([tonkin], result.find_racers(event).to_a, 'first_name + last_name')
    
    result = race.results.new(:name => 'Erik Tonkin')
    assert_equal([tonkin], result.find_racers(event).to_a, 'name')
    
    result = race.results.new(:last_name => 'Tonkin')
    assert_equal([tonkin], result.find_racers(event).to_a, 'last_name')
    
    result = race.results.new(:first_name => 'Erik')
    assert_equal([tonkin], result.find_racers(event).to_a, 'first_name')
    
    result = race.results.new(:first_name => 'Erika', :last_name => 'Tonkin')
    assert_equal([], result.find_racers(event).to_a, 'first_name + last_name should not match')
    
    result = race.results.new(:name => 'Erika Tonkin')
    assert_equal([], result.find_racers(event).to_a, 'name should not match')
    
    result = race.results.new(:last_name => 'onkin')
    assert_equal([], result.find_racers(event).to_a, 'last_name should not match')
    
    result = race.results.new(:first_name => 'Erika')
    assert_equal([], result.find_racers(event).to_a, 'first_name should not match')
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :number => '104')
    assert_equal([tonkin], result.find_racers(event).to_a, 'road number, first_name, last_name')
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :number => '340')
    assert_equal([tonkin], result.find_racers(event).to_a, 'Matson road number, first_name, last_name')
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :number => '6')
    assert_equal([tonkin], result.find_racers(event).to_a, 'cross number (not in DB), first_name, last_name')
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :number => '1')
    assert_equal([tonkin], result.find_racers(event).to_a, 'Different number')
    
    # TODO make null racer and list this match as a possibility
    result = race.results.new(:first_name => 'Rhonda', :last_name => 'Tonkin', :number => '104')
    assert_equal([], result.find_racers(event).to_a, 'Tonkin\'s number, different first name')
    
    # TODO make null racer and list this match as a possibility
    result = race.results.new(:first_name => 'Erik', :last_name => 'Viking', :number => '104')
    assert_equal([], result.find_racers(event).to_a, 'Tonkin\'s number, different last name')

    tonkin_clone = Racer.create(:first_name => 'Erik', :last_name => 'Tonkin')
    RaceNumber.create(:racer => tonkin_clone, :number_issuer => number_issuers(:association), :discipline => Discipline[:road], :year => 2004, :value => '1')
    unless tonkin_clone.valid?
      flunk(tonkin_clone.errors.full_messages)
    end

    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'Same names, no numbers')
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :number => '6')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'Same names, bogus numbers')
    
    result = race.results.new(:last_name => 'Tonkin')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'Same last name')
    
    result = race.results.new(:first_name => 'Erik')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'Same names, bogus numbers')
    
    result = race.results.new(:number => '6')
    assert_equal([], result.find_racers(event).to_a, 'ccx number (not in DB)')
    
    result = race.results.new(:number => '104')
    assert_equal([tonkin], result.find_racers(event).to_a, 'road number, first_name, last_name')

    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :number => '104')
    assert_equal([tonkin], result.find_racers(event).to_a, 'road number, first_name, last_name')

    result = race.results.new(:number => '1')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'road number')

    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :number => '1')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'road number, first_name, last_name')

    # team_name -- consider last
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona')
    assert_equal([tonkin], result.find_racers(event).to_a, 'first_name, last_name, team')

    # TODO: change to possible match
    result = race.results.new(:first_name => 'Erika', :last_name => 'Tonkin', :team_name => 'Kona')
    assert_equal([], result.find_racers(event).to_a, 'wrong first_name, last_name, team')

    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona', :number => '104')
    assert_equal([tonkin], result.find_racers(event).to_a, 'first_name, last_name, team, number')

    result = race.results.new(:last_name => 'Tonkin', :team_name => 'Kona')
    assert_equal([tonkin], result.find_racers(event).to_a, 'last_name, team')
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => '')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'first_name, last_name, blank team')
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Camerati')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'first_name, last_name, wrong team')
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Camerati', :number => '987')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'first_name, last_name, wrong team, wrong number')
    
    tonkin_clone.team = teams(:vanilla)
    tonkin_clone.save!
    
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Vanilla Bicycles')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'first_name, last_name + team alias should match')

    result = race.results.new
    assert_equal([], result.find_racers(event).to_a, 'no racer, team, nor number')

    result = race.results.new(:team_name => 'Astana Wurth')
    assert_equal([], result.find_racers(event).to_a, 'wrong team only')

    # rental numbers
    result = race.results.new(:first_name => 'Erik', :last_name => 'Tonkin', :number => '60')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'rental number')

    result = race.results.new(:first_name => '', :last_name => '')
    assert_same_elements([], result.find_racers(event).to_a, 'blank name with no blank names')

    blank_name_racer = Racer.create(:name => '', :dh_number => '1')
    result = race.results.new(:first_name => '', :last_name => '')
    assert_same_elements([blank_name_racer], result.find_racers(event).to_a, 'blank names')

    # Add exact dupes with same numbers
    # Test numbers from different years or disciplines
  end
  
  def test_multiple_scores_for_same_race
    competition = Competition.create(:name => 'KOM')
    competition_race = competition.standings.first.races.create(:category => categories(:cx_a))
    competition_result = competition_race.results.create(:racer => racers(:tonkin), :points => 5)
    
    standings = standings(:kings_valley_2004)
    race = standings.races.create(:category => categories(:cx_a))
    source_result = race.results.create(:racer => racers(:tonkin))
    
    assert(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 10))
    
    source_result = races(:jack_frost_pro_1_2).results.build(:racer => racers(:tonkin))    
    assert(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 10))
    
    source_result = races(:jack_frost_pro_1_2).results.build(:racer => racers(:tonkin))    
    assert_nil(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 10))
    
    # Need a lot more tests
    competition_race = competition.standings.first.races.create(:category => categories(:expert_junior_men))
    race = standings.races.create(:category => categories(:expert_junior_men))
    source_result = races(:jack_frost_pro_1_2).results.build(:team => teams(:vanilla))    
    competition_result = competition_race.results.create(:team => teams(:vanilla))
    assert(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 10))
    source_result = races(:jack_frost_pro_1_2).results.build(:team => teams(:vanilla))    
    assert_not_nil(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 2))
    source_result = races(:jack_frost_masters_35_plus_women).results.build(:team => teams(:vanilla))    
    assert(competition_result.scores.create_if_best_result_for_race(:source_result => source_result, :points => 4))
  end
  
  def test_find_for_racer
    mollie = racers(:mollie)
    results = Result.find_for(mollie)
    assert_not_nil(results)
    assert_equal(3, results.size, 'Results')
    
    results = Result.find_for(mollie.id)
    assert_not_nil(results)
    assert_equal(3, results.size, 'Results')    
  end
end