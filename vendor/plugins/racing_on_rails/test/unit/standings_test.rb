require File.dirname(__FILE__) + '/../test_helper'

class StandingsTest < Test::Unit::TestCase
  
  fixtures :teams, :aliases, :users, :promoters, :categories, :racers, :events, :standings, :races, :results, :disciplines, :discipline_bar_categories, :aliases_disciplines

  def test_new
    bb3 = events(:banana_belt_3)
    standings = bb3.standings.create
    assert(standings.races.empty?, "Standings should have empty races")
    assert_equal(bb3.date, standings.date, "New standings should have event date")
    assert_equal(bb3.date, standings[:date], "New standings should have copy of event date after save")
    assert_equal(bb3.name, standings.name, "race name")
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
    standings_1 = bb3.standings.build(:event => bb3)
    standings_2 = bb3.standings.build(:event => bb3)
    standings_3 = bb3.standings.build(:event => bb3)
    
    assert_equal(0, standings_1.position, 'Standings 1 position')
    assert_equal(0, standings_2.position, 'Standings 2 position')
    assert_equal(0, standings_3.position, 'Standings 3 position')
    
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
    jack_frost = events(:jack_frost)
    assert_equal(1, jack_frost.standings.size, 'standings.size')
    categorized_standings = jack_frost.standings.first
    assert_equal(2, categorized_standings.races.size, 'races')
    assert_equal(3, categorized_standings.races.first.results.size + categorized_standings.races.last.results.size, 'total number of results')
    
    categorized_standings.create_or_destroy_combined_standings
    combined_standings = categorized_standings.combined_standings
    combined_standings.recalculate
    
    assert_equal(false, combined_standings.ironman, 'Ironman')
    
    assert_equal('Jack Frost Combined', combined_standings.name, 'name')
    assert_equal(0, combined_standings.bar_points, 'bar points')
    assert_equal(1, combined_standings.races.size, 'combined_standings.races')
    combined = combined_standings.races.first
    assert_equal(3, combined.results.size, 'combined.results')

    result = combined.results[0]
    assert_equal('1', result.place, 'place')
    assert_equal(racers(:mollie), result.racer, 'racer')
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
    standings = event.standings.create!
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
    standings = event.standings.create!
    event.reload
    assert_equal(2, event.standings.size, 'New MTB standings should create combined standings')
    
    standings.reload
    standings.destroy
    event.reload
    assert_equal(0, event.standings.size, 'MTB standings and combined standings should be deleted')
  end

  def test_combined_mtb_standings
    results_from_fixtures = Result.find(:all)
    event = SingleDayEvent.create(:name => 'Reheers', :discipline => 'Mountain Bike')
    event.disable_notification!
    assert(event.errors.empty?, event.errors.full_messages)
    standings = event.standings.create

    pro_semi_pro_elite_men = categories(:pro_semi_pro_elite_men)
    pro_men = Category.create(:name => 'Pro Men', :bar_category => pro_semi_pro_elite_men)
    race = standings.races.create(:category => pro_men)
    tonkin = racers(:tonkin)
    tonkin_result = race.results.create(:place => '1', :racer => tonkin, :time_s => '2:12:34')
    larsen = Racer.create(:name => 'Steve Larsen')
    larsen_result = race.results.create(:place => '2', :racer => larsen, :time_s => '2:13:00')
    decker = Racer.create(:name => 'Carl Decker')
    decker_result = race.results.create(:place => '3', :racer => decker, :time_s => '2:18:59')

    semi_pro_men = Category.create(:name => 'Semi-Pro Men', :bar_category => pro_semi_pro_elite_men)
    race = standings.races.create(:category => semi_pro_men)
    brandt = Racer.create(:name => 'Chris Brandt')
    brandt_result = race.results.create(:place => '1', :racer => brandt, :time_s => '2:13:01')
    bear = Racer.create(:name => 'Bear Perrin')
    bear_result = race.results.create(:place => '2', :racer => bear, :time_s => '2:14:15')
    chad = Racer.create(:name => 'Chad Swanson')
    chad_result = race.results.create(:place => '3', :racer => chad, :time_s => '2:32:00')

    elite_men = Category.create(:name => 'Elite Men', :bar_category => pro_semi_pro_elite_men)
    race = standings.races.create(:standings => standings, :category => elite_men)
    chris_myers = Racer.create(:name => 'Chris Myers')
    chris_myers_result = race.results.create(:place => '1', :racer => chris_myers, :time_s => '2:12:45')
    matt_braun = Racer.create(:name => 'Mathew Braun')
    matt_braun_result = race.results.create(:place => '2', :racer => matt_braun, :time_s => '2:24:31')
    greg_tyler = Racer.create(:name => 'Greg Tyler')
    greg_tyler_result = race.results.create(:place => '3', :racer => greg_tyler, :time_s => '3:03:01')

    expert_men_bar = Category.create(:name => 'Expert Men', :scheme => 'BAR')
    expert_men = Category.create(:name => 'Expert Men', :bar_category => expert_men_bar)
    race = standings.races.create(:standings => standings, :category => expert_men)
    weaver = racers(:weaver)
    weaver_result = race.results.create(:place => '1', :racer => weaver, :time_s => '2:15:56')
    mahoney = Racer.create(:name => 'Matt Mahoney')
    mahoney_result = race.results.create(:place => '2', :racer => mahoney, :time_s => '2:33:11')
    sam = Racer.create(:name => 'Sam Richardson')
    sam_result = race.results.create(:place => '3', :racer => sam, :time_s => '3:01:19')

    pro_elite_expert_women = categories(:pro_elite_expert_women)
    pro_women = Category.create(:name => 'Pro Women', :bar_category => pro_elite_expert_women)
    race = standings.races.create(:standings => standings, :category => pro_women)
    mollie = racers(:mollie)
    mollie_result = race.results.create(:place => '1', :racer => mollie, :time_s => '1:41:37')
    alice = racers(:alice)
    alice_result = race.results.create(:place => '2', :racer => alice, :time_s => '1:43:55')
    rita = Racer.create(:name => 'Rita Metermaid')
    rita_result = race.results.create(:place => '3', :racer => rita, :time_s => '2:13:33')

    elite_women = Category.create(:name => 'Elite Women', :bar_category => pro_elite_expert_women)
    race = standings.races.create(:standings => standings, :category => elite_women)
    laurel = Racer.create(:name => 'Laurel')
    laurel_result = race.results.create(:place => '1', :racer => laurel, :time_s => '1:41:38')
    shari = Racer.create(:name => 'Shari')
    shari_result = race.results.create(:place => '2', :racer => shari, :time_s => '2:24:31')
    ann = Racer.create(:name => 'Ann')
    ann_result = race.results.create(:place => '3', :racer => ann, :time_s => '3:03:01')

    expert_women = Category.create(:name => 'Expert Women', :bar_category => pro_elite_expert_women)
    race = standings.races.create(:category => expert_women)
    expert_woman_1 = Racer.create(:name => 'Expert Woman 1')
    expert_woman_1_result = race.results.create(:place => '1', :racer => expert_woman_1, :time_s => '1:00:00')
    expert_woman_2 = Racer.create(:name => 'Expert Woman 2')
    expert_woman_2_result = race.results.create(:place => '2', :racer => expert_woman_2, :time_s => '2:00:00')
    expert_woman_3 = Racer.create(:name => 'Expert Woman 3')
    expert_woman_3_result = race.results.create(:place => '3', :racer => expert_woman_3, :time_s => '3:03:03')

    sport_women_bar = Category.create(:name => 'Sport Women', :scheme => 'BAR')
    sport_women = Category.create(:name => 'Sport Women', :bar_category => sport_women_bar)
    race = standings.races.create(:category => sport_women)
    sport_woman_1 = Racer.create(:name => 'Sport Woman 1')
    sport_woman_1_result = race.results.create(:place => '1', :racer => sport_woman_1, :time_s => '1:10:00')
    sport_woman_2 = Racer.create(:name => 'Sport Woman 2')
    sport_woman_2_result = race.results.create(:place => '2', :racer => sport_woman_2, :time_s => '2:05:00')
    sport_woman_3 = Racer.create(:name => 'Sport Woman 3')
    sport_woman_3_result = race.results.create(:place => '3', :racer => sport_woman_3, :time_s => '3:30:01')

    event.enable_notification!
    standings.create_or_destroy_combined_standings
    combined_standings = standings.combined_standings
    assert_equal(false, combined_standings.ironman, 'Ironman')
    combined_standings.recalculate
    
    event.reload
    assert_equal(2, event.standings.count, 'Event standings (results + combined standings)')
    assert_equal(2, event.standings.count, 'Event standings (results + combined standings)')
    assert_not_nil(combined_standings, 'Combined Pro, Semi-Pro, Elite, Expert standings')
    assert_equal(2, combined_standings.races.size, 'Combined Standings races')

    mens_combined = combined_standings.races.detect {|race| race.category == categories(:pro_semi_pro_elite_men)}
    assert_not_nil(mens_combined, "Mens combined race")
    expected = [
      tonkin_result,
      chris_myers_result,
      larsen_result,
      brandt_result,
      bear_result,
      decker_result,
      matt_braun_result,
      chad_result,
      greg_tyler_result
    ]
    assert_results(expected, mens_combined.results(true), mens_combined.name)
    assert_equal(1, mens_combined.bar_points, 'Mens combined BAR points')
    original_standings = event.standings.detect {|standings| !standings.name['Combined']}
    for race in original_standings.races
      if race.bar_category == pro_semi_pro_elite_men || race.bar_category == pro_elite_expert_women
        assert_equal(0, race.bar_points, 'Original pro and elite races BAR points')
      end
    end

    women_combined = combined_standings.races.detect {|race| race.category == categories(:pro_elite_expert_women)}
    assert_not_nil(women_combined, "Women combined race")
    expected = [
      expert_woman_1_result,
      mollie_result,
      laurel_result,
      alice_result,
      expert_woman_2_result,
      rita_result,
      shari_result,
      ann_result,
      expert_woman_3_result
    ]
    assert_results(expected, women_combined.results(true))
    assert_equal(1, women_combined.bar_points, 'Women combined BAR points')

    # recreate -- should be same
    combined_standings.recalculate
    event.reload
    assert_equal(2, event.standings.count, 'Event standings (results + combined standings)')
    combined_standings = event.standings.detect {|standings| standings.name['Combined']}
    assert_not_nil(combined_standings, 'Combined Pro, Semi-Pro, Elite standings')
    assert_equal(2, combined_standings.races.size, 'Combined Standings races')

    # Potential changes
    # Result deleted, added
    # Result Racer changed
    # Result time changed
    # Delete standings in no results
    # delete standings -- delete combined

    results_before_bar_recalc = Result.find(:all)
    Bar.recalculate
    results_after_bar_recalc = Result.find(:all)
    assert(results_after_bar_recalc.size > results_before_bar_recalc.size, 'Should have new BAR results')

    original_standings.reload
    original_standings.destroy
    assert(original_standings.errors.empty?, original_standings.errors.full_messages)
    assert_raises(ActiveRecord::RecordNotFound, 'Standings should be deleted') {Standings.find(original_standings.id)}
    assert_raises(ActiveRecord::RecordNotFound, 'Combined standings should be deleted') {Standings.find(combined_standings.id)}

    Bar.recalculate
    results_after_bar_recalc = Result.find(:all)
    assert_equal(results_from_fixtures.size, results_after_bar_recalc.size, 'Should have no new results')
  end
  
  def test_races_with_results
    bb3 = events(:banana_belt_3)
    standings = bb3.standings.create!
    assert(standings.races_with_results.empty?, 'No races')
    
    sr_p_1_2 = categories(:sr_p_1_2)
    standings.races.create(:category => sr_p_1_2)
    assert(standings.races_with_results.empty?, 'No results')
    
    sr_women = categories(:sr_women)
    race_1 = standings.races.create(:category => sr_women)
    race_1.results.create!
    assert_equal([race_1], standings.races_with_results, 'One results')
    
    race_2 = standings.races.create(:category => sr_p_1_2)
    race_2.results.create!
    women_4 = categories(:women_4)
    standings.races.create(:category => women_4)
    assert_equal([race_2, race_1], standings.races_with_results, 'Two races with results')
    
    standings.discipline = 'Time Trial'
    standings.save!
    combined_standings = standings.combined_standings
    assert_not_nil(combined_standings, 'Combined standings')
    assert_equal([race_2, race_1], standings.races_with_results, 'Two races with results')
    race_3 = combined_standings.races.first
    race_3.results.create!
    assert(!race_3.results(true).empty?, 'Combined standings should have results')
    assert_equal([race_2, race_1, race_3], standings.races_with_results, 'Two races with results')
  end
end