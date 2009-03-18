require "test_helper"

class ResultTest < ActiveSupport::TestCase
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
    assert(results[3].place.blank?, 'result 3 place blank')
    assert(results[4].place.blank?, 'result 4 place blank')
    assert(results[5].place.blank?, 'result 5 place blank')
    assert_equal('DNF', results[6].place, 'result 6 place')
    assert_equal('DNS', results[7].place, 'result 7 place')

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
    assert(results[3].place.blank?, 'result 3 place blank')
    assert(results[4].place.blank?, 'result 4 place blank')
    assert_equal('DNF', results[5].place, 'result 5 place')

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
    assert(results[3].place.blank?, 'result 3 place blank')
    assert_equal('DNF', results[4].place, 'result 4 place')
    assert_equal('DQ', results[5].place, 'result 5 place')

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
    result = results.create!(:place => 1, :first_name => 'Clara', :last_name => 'Willson', :number => '300')
    assert(result.racer.errors.empty?, "Racers should have no errors, but had: #{result.racer.errors.full_messages}")
    assert_nil(result.racer(true).road_number(true), 'Current road number')
    road_number_2004 = result.racer.race_numbers.detect{|number| number.year == 2004}
    assert_not_nil(road_number_2004.value, '2004 road number')
    assert_equal('300', road_number_2004.value, '2004 road number')
    assert(result.racer.ccx_number.blank?, 'Cyclocross number')
    assert(result.racer.xc_number.blank?, 'MTB number')

    event = SingleDayEvent.create!(:discipline => "Road")
    standings = event.standings.create!
    race = standings.races.create!(:category => categories(:senior_women))
    result = race.results.create!(:place => 2, :first_name => 'Eddy', :last_name => 'Merckx', :number => '200')
    assert(result.racer.errors.empty?, "Racers should have no errors, but had: #{result.racer.errors.full_messages}")
    road_number = result.racer(true).race_numbers(true).detect{|number| number.year == Date.today.year}
    assert_not_nil(road_number, 'Current road number')
    assert_equal('200', road_number.value, 'road number')
    assert_equal(Date.today.year, road_number.year, 'road number year')
    assert(result.racer.ccx_number.blank?, 'Cyclocross number')
    assert(result.racer.xc_number.blank?, 'MTB number')
    assert(result.racer.member?, "Racer should be member")

    # Rental
    begin
      original_rental_numbers = ASSOCIATION.rental_numbers
      ASSOCIATION.rental_numbers = 0..99
      result = race.results.create!(:place => 2, :first_name => 'Benji', :last_name => 'Whalen', :number => '51')
      assert(result.racer.errors.empty?, "Racers should have no errors, but had: #{result.racer.errors.full_messages}")
      road_number = result.racer(true).race_numbers(true).detect{|number| number.year == Date.today.year}
      assert_nil(road_number, 'Current road number')
      assert(!result.racer.member?, "Racer with rental number should not be member")
    ensure
      ASSOCIATION.rental_numbers = original_rental_numbers
    end
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
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin')
    assert_equal([tonkin], result.find_racers(event).to_a, 'first_name + last_name')
    
    result = race.results.build(:name => 'Erik Tonkin')
    assert_equal([tonkin], result.find_racers(event).to_a, 'name')
    
    result = race.results.build(:last_name => 'Tonkin')
    assert_equal([tonkin], result.find_racers(event).to_a, 'last_name')
    
    result = race.results.build(:first_name => 'Erik')
    assert_equal([tonkin], result.find_racers(event).to_a, 'first_name')
    
    result = race.results.build(:first_name => 'Erika', :last_name => 'Tonkin')
    assert_equal([], result.find_racers(event).to_a, 'first_name + last_name should not match')
    
    result = race.results.build(:name => 'Erika Tonkin')
    assert_equal([], result.find_racers(event).to_a, 'name should not match')
    
    result = race.results.build(:last_name => 'onkin')
    assert_equal([], result.find_racers(event).to_a, 'last_name should not match')
    
    result = race.results.build(:first_name => 'Erika')
    assert_equal([], result.find_racers(event).to_a, 'first_name should not match')
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '104')
    assert_equal([tonkin], result.find_racers(event).to_a, 'road number, first_name, last_name')
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '340')
    assert_equal([tonkin], result.find_racers(event).to_a, 'Matson road number, first_name, last_name')
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '6')
    assert_equal([tonkin], result.find_racers(event).to_a, 'cross number (not in DB), first_name, last_name')
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '100')
    assert_equal([tonkin], result.find_racers(event).to_a, 'Different number')
    
    # TODO make null racer and list this match as a possibility
    result = race.results.build(:first_name => 'Rhonda', :last_name => 'Tonkin', :number => '104')
    assert_equal([], result.find_racers(event).to_a, 'Tonkin\'s number, different first name')
    
    # TODO make null racer and list this match as a possibility
    result = race.results.build(:first_name => 'Erik', :last_name => 'Viking', :number => '104')
    assert_equal([], result.find_racers(event).to_a, 'Tonkin\'s number, different last name')

    tonkin_clone = Racer.create(:first_name => 'Erik', :last_name => 'Tonkin')
    RaceNumber.create(:racer => tonkin_clone, :number_issuer => number_issuers(:association), :discipline => Discipline[:road], :year => 2004, :value => '100')
    unless tonkin_clone.valid?
      flunk(tonkin_clone.errors.full_messages)
    end

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'Same names, no numbers')
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '6')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'Same names, bogus numbers')
    
    result = race.results.build(:last_name => 'Tonkin')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'Same last name')
    
    result = race.results.build(:first_name => 'Erik')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'Same names, bogus numbers')
    
    result = race.results.build(:number => '6')
    assert_equal([], result.find_racers(event).to_a, 'ccx number (not in DB)')
    
    result = race.results.build(:number => '104')
    assert_equal([tonkin], result.find_racers(event).to_a, 'road number, first_name, last_name')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '104')
    assert_equal([tonkin], result.find_racers(event).to_a, 'road number, first_name, last_name')

    result = race.results.build(:number => '100')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'road number')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '100')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'road number, first_name, last_name')

    # team_name -- consider last
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona')
    assert_equal([tonkin], result.find_racers(event).to_a, 'first_name, last_name, team')

    # TODO: change to possible match
    result = race.results.build(:first_name => 'Erika', :last_name => 'Tonkin', :team_name => 'Kona')
    assert_equal([], result.find_racers(event).to_a, 'wrong first_name, last_name, team')

    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Kona', :number => '104')
    assert_equal([tonkin], result.find_racers(event).to_a, 'first_name, last_name, team, number')

    result = race.results.build(:last_name => 'Tonkin', :team_name => 'Kona')
    assert_equal([tonkin], result.find_racers(event).to_a, 'last_name, team')
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => '')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'first_name, last_name, blank team')
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Camerati')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'first_name, last_name, wrong team')
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Camerati', :number => '987')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'first_name, last_name, wrong team, wrong number')
    
    tonkin_clone.team = teams(:vanilla)
    tonkin_clone.save!
    
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :team_name => 'Vanilla Bicycles')
    assert_equal([tonkin_clone], result.find_racers(event).to_a, 'first_name, last_name + team alias should match')

    result = race.results.build
    assert_equal([], result.find_racers(event).to_a, 'no racer, team, nor number')

    result = race.results.build(:team_name => 'Astana Wurth')
    assert_equal([], result.find_racers(event).to_a, 'wrong team only')

    # rental numbers
    result = race.results.build(:first_name => 'Erik', :last_name => 'Tonkin', :number => '60')
    assert_same_elements([tonkin, tonkin_clone], result.find_racers(event).to_a, 'rental number')

    result = race.results.build(:first_name => '', :last_name => '')
    assert_same_elements([], result.find_racers(event).to_a, 'blank name with no blank names')

    blank_name_racer = Racer.create(:name => '', :dh_number => '100')
    result = race.results.build(:first_name => '', :last_name => '')
    assert_same_elements([blank_name_racer], result.find_racers(event).to_a, 'blank names')

    # Add exact dupes with same numbers
    # Test numbers from different years or disciplines
  end
  
  def test_assign_results_to_existing_racer_with_same_name_instead_of_creating_a_new_one
    new_tonkin = Racer.create!(:name => "Erik Tonkin")
    assert_equal(2, Racer.find_all_by_name("Erik Tonkin").size, "Should have 2 Tonkins")
    assert_equal(2, Racer.find_all_by_name_or_alias("Erik", "Tonkin").size, "Should have 2 Tonkins")

    # A very old result
    SingleDayEvent.create!(:date => Date.new(1980)).standings.create!.races.create!(:category => categories(:cx_a)).results.create!(:racer => new_tonkin)
    
    kings_valley_2004 = events(:kings_valley_2004)
    results = races(:kings_valley_pro_1_2_2004).results
    result = results.create(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin')

    assert_equal(2, Racer.find_all_by_name("Erik Tonkin").size, "Should not create new Tonkin")
    assert_equal(racers(:tonkin), result.racer, "Should use racer with most recent result")
  end
  
  def test_most_recent_racer_if_no_results
    new_tonkin = Racer.create!(:name => "Erik Tonkin")
    assert_equal(2, Racer.find_all_by_name("Erik Tonkin").size, "Should have 2 Tonkins")
    assert_equal(2, Racer.find_all_by_name_or_alias("Erik", "Tonkin").size, "Should have 2 Tonkins")

    tonkin = racers(:tonkin)
    tonkin.results.clear
    
    kings_valley_2004 = events(:kings_valley_2004)
    results = races(:kings_valley_pro_1_2_2004).results
    result = results.create(:place => 1, :first_name => 'Erik', :last_name => 'Tonkin')

    assert_equal(2, Racer.find_all_by_name("Erik Tonkin").size, "Should not create new Tonkin")
    assert_equal(new_tonkin, result.racer, "Should use most recently-updated racer if can't decide otherwise")
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
  
  def test_find_all_for_racer
    molly = racers(:molly)
    results = Result.find_all_for(molly)
    assert_not_nil(results)
    assert_equal(3, results.size, 'Results')
    
    results = Result.find_all_for(molly.id)
    assert_not_nil(results)
    assert_equal(3, results.size, 'Results')    
  end
  
  def test_last_event?
    result = Result.new
    assert(!result.last_event?, "New result should not be last event")

    event = SingleDayEvent.new(:name => "Tabor CR", :discipline => 'Road')
    event.save!
    standings = Standings.new(:event => event)
    standings.save!
    category = Category.find_by_name("Senior Men Pro 1/2")
    race = Race.new(:standings => standings, :category => category)
    race.save!
    result = race.results.build
    assert(result.last_event?, "Only event should be last event")
    
    # Series standings
    series_result = events(:banana_belt_series).standings.create!.races.create!(:category => category).results.create!
    assert(!series_result.last_event?, "Series result should not be last event")
    
    # First event
    first_result = events(:banana_belt_1).standings.create!.races.create!(:category => category).results.create!
    assert(!first_result.last_event?, "First result should not be last event")
    
    # Second (and last) event
    second_result = events(:banana_belt_2).standings.create!.races.create!(:category => category).results.create!
    assert(result.last_event?, "Last event should be last event")    
  end
  
  def test_finished?
    category = Category.find_by_name("Senior Men Pro 1/2")
    race = SingleDayEvent.create!.standings.create!.races.create!(:category => category)
    
    result = race.results.create!(:place => "1")
    assert(result.finished?, "'1' should be a finisher")
    
    result = race.results.create!(:place => nil)
    assert(!result.finished?, "nil should not be a finisher")
    
    result = race.results.create!(:place => "")
    assert(!result.finished?, "'' should not be a finisher")
    
    result = race.results.create!(:place => "1000")
    assert(result.finished?, "'1000' should be a finisher")
    
    result = race.results.create!(:place => "DNF")
    assert(!result.finished?, "'DNF' should not be a finisher")
    
    result = race.results.create!(:place => "dnf")
    assert(!result.finished?, "'dnf' should not be a finisher")
    
    result = race.results.create!(:place => "DQ")
    assert(!result.finished?, "'DNF' should not be a finisher")
    
    result = race.results.create!(:place => "some_non_numeric_place")
    assert(!result.finished?, "'some_non_numeric_place' should not be a finisher")
    
    result = race.results.create!(:place => "some_non_numeric_place_9")
    assert(!result.finished?, "'some_non_numeric_place_9' should not be a finisher")
    
    result = race.results.create!(:place => "1st")
    assert(result.finished?, "'1st' should be a finisher")
    
    result = race.results.create!(:place => "4th")
    assert(result.finished?, "'4th' should not be a finisher")
  end
  
  def test_make_member_if_association_number
    standings = SingleDayEvent.create!(:name => "Tabor CR").standings.create!
    race = standings.races.create!(:category => Category.find_by_name("Senior Men Pro 1/2"))
    result = race.results.create!(
      :first_name => "Tom", :last_name => "Boonen", :team_name => "Davitamon", :number => "702"
    )
    
    racer = result.racer
    racer.reload
    
    assert(racer.member?, "Finisher with racing association number should be member")
  end
  
  def test_do_not_make_member_if_not_association_number
    number_issuer = NumberIssuer.create!(:name => "Tabor")
    standings = SingleDayEvent.create!(:name => "Tabor CR", :number_issuer => number_issuer).standings.create!
    race = standings.races.create!(:category => Category.find_by_name("Senior Men Pro 1/2"))
    result = race.results.create!(
      :first_name => "Tom", :last_name => "Boonen", :team_name => "Davitamon", :number => "702"
    )
    
    racer = result.racer
    racer.reload
    
    assert(!racer.member?, "Finisher with event (not racing association) number should be member")
  end
  
  def test_only_make_member_if_full_name
    standings = SingleDayEvent.create!(:name => "Tabor CR").standings.create!
    race = standings.races.create!(:category => Category.find_by_name("Senior Men Pro 1/2"))
    result = race.results.create!(
      :first_name => "Tom", :team_name => "Davitamon", :number => "702"
    )
    result_2 = race.results.create!(
      :last_name => "Boonen", :team_name => "Davitamon", :number => "702"
    )
    
    result.racer.reload
    assert(!result.racer.member?, "Finisher with only first_name should be not member")
    
    result_2.racer.reload
    assert(!result_2.racer.member?, "Finisher with only last_name should be not member")
  end
  
  def test_stable_name_on_old_results
    team = Team.create!(:name => "Tecate-Una Mas")

    event = SingleDayEvent.create!(:date => 1.years.ago)
    old_result = event.standings.create!.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    team.historical_names.create!(:name => "Twin Peaks", :year => 1.years.ago.year)
    
    event = SingleDayEvent.create!(:date => Date.today)
    result = event.standings.create!.races.create!(:category => categories(:senior_men)).results.create!(:team => team)    
    
    assert_equal("Tecate-Una Mas", result.team_name, "Team name on this year's result")
    assert_equal("Twin Peaks", old_result.team_name, "Team name on old result")
  end
  
  def test_bar
    standings = SingleDayEvent.create!(:name => "Tabor CR").standings.create!
    race = standings.races.create!(:category => Category.find_by_name("Senior Men Pro 1/2"))
    result = race.results.create!(
      :first_name => "Tom", :team_name => "Davitamon", :number => "702"
    )
    assert(result.bar?, "By default, results should count toward BAR")
    result.bar = false
    assert(!result.bar?, "Result bar?")
  end
end