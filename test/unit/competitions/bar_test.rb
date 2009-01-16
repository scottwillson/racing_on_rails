# There is duplication between BAR tests, but refactring the tests should wait until the Competition refactoring is complete
# FIXME Assert correct team names on BAR results

require "test_helper"

class BarTest < ActiveSupport::TestCase
  
  def test_find_or_create_by_date
    date = Date.today(2006)
    bar = Bar.find_or_create_by_date(date)
    assert_not_nil(bar, 'Should create BAR')

    bar = Bar.find_or_create_by_date(date)
    assert_not_nil(bar, 'Should find BAR')
  end
  
  def test_recalculate
    # Lot of set-up for BAR. Keep it out of fixtures and do one-time here.
    
    cross_crusade = Series.create!(:name => "Cross Crusade")
    barton = SingleDayEvent.create!({
      :name => "Cross Crusade: Barton Park",
      :discipline => "Cyclocross",
      :date => Date.new(2004, 11, 7),
      :parent => cross_crusade
    })
    barton_standings = barton.standings.create
    men_a = Category.find_by_name("Men A")
    barton_a = barton_standings.races.create(:category => men_a, :field_size => 5)
    barton_a.results.create({
      :place => 3,
      :racer => racers(:tonkin)
    })
    barton_a.results.create({
      :place => 15,
      :racer => racers(:weaver)
    })
    barton_a.results.create({
      :place => 2,
      :racer => racers(:alice),
      :bar => false
    })
    
    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    })
    swan_island_standings = swan_island.standings.create
    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    swan_island_senior_men = swan_island_standings.races.create(:category => senior_men, :field_size => 4)
    swan_island_senior_men.results.create({
      :place => 12,
      :racer => racers(:tonkin)
    })
    swan_island_senior_men.results.create({
      :place => 2,
      :racer => racers(:molly)
    })
    senior_women = Category.find_by_name("Senior Women")
    senior_women_swan_island = swan_island_standings.races.create(:category => senior_women, :field_size => 3)
    senior_women_swan_island.results.create({
      :place => 1,
      :racer => racers(:molly)
    })
    # No BAR points
    senior_women_swan_island.bar_points = 0
    senior_women_swan_island.save!
    
    thursday_track_series = Series.create!(:name => "Thursday Track")
    thursday_track = SingleDayEvent.create!({
      :name => "Thursday Track",
      :discipline => "Track",
      :date => Date.new(2004, 5, 12),
      :parent => thursday_track_series
    })
    thursday_track_standings = thursday_track.standings.create
    thursday_track_senior_men = thursday_track_standings.races.create(:category => senior_men, :field_size => 6)
    r = thursday_track_senior_men.results.create(
      :place => 5,
      :racer => racers(:weaver)
    )
    thursday_track_senior_men.results.create(
      :place => 14,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    )
    
    team_track = SingleDayEvent.create!({
      :name => "Team Track State Championships",
      :discipline => "Track",
      :date => Date.new(2004, 9, 1)
    })
    team_track_standings = team_track.standings.create
    team_track_standings.bar_points = 2
    team_track_standings.save!
    team_track_senior_men = team_track_standings.races.create(:category => senior_men, :field_size => 6)
    team_track_senior_men.results.create({
      :place => 1,
      :racer => racers(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create({
      :place => 1,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create({
      :place => 1,
      :racer => racers(:molly)
    })
    team_track_senior_men.results.create({
      :place => 5,
      :racer => racers(:alice)
    })
    team_track_senior_men.results.create({
      :place => 5,
      :racer => racers(:matson)
    })
    # Weaver and Erik's second ride should not count
    team_track_senior_men.results.create({
      :place => 15,
      :racer => racers(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create({
      :place => 15,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    })
    
    larch_mt_hillclimb = SingleDayEvent.create!({
      :name => "Larch Mountain Hillclimb",
      :discipline => "Time Trial",
      :date => Date.new(2004, 2, 1)
    })
    larch_mt_hillclimb_standings = larch_mt_hillclimb.standings.create(:event => larch_mt_hillclimb)
    larch_mt_hillclimb_senior_men = larch_mt_hillclimb_standings.races.create(:category => senior_men, :field_size => 6)
    larch_mt_hillclimb_senior_men.results.create({
      :place => 13,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    })
  
    results_baseline_count = Result.count
    assert_equal(0, Bar.count, "Bar standings before recalculate")
    original_results_count = Result.count
    Bar.recalculate(2004)
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Bar after recalculate")
    assert_equal(1, Bar.count, "Bar events after recalculate")
    assert_equal(7, bar.standings.count, "Bar standings after recalculate " + bar.standings.collect {|s| s.name}.join(', '))
    assert_equal(original_results_count + 15, Result.count, "Total count of results in DB")
    # Should delete old BAR
    Bar.recalculate(2004)
    assert_equal(1, Bar.count, "Bar events after recalculate")
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Bar after recalculate")
    assert_equal(7, bar.standings.count, "Bar standings after recalculate")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 Bar date")
    assert_equal("2004 BAR", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "BAR last updated")
    assert_equal(original_results_count + 15, Result.count, "Total count of results in DB")
    
    road_bar = bar.standings.detect {|s| s.name == "Road" }
    women_road_bar = road_bar.races.detect {|b| b.name == "Senior Women" }
    assert_equal(categories(:senior_women), women_road_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(2, women_road_bar.results.size, "Senior Women Road BAR results")

    women_road_bar.results.sort!
    assert_equal(racers(:alice), women_road_bar.results[0].racer, "Senior Women Road BAR results racer")
    assert_equal("1", women_road_bar.results[0].place, "Senior Women Road BAR results place")
    assert_equal(25, women_road_bar.results[0].points, "Senior Women Road BAR results points")

    assert_equal(racers(:molly), women_road_bar.results[1].racer, "Senior Women Road BAR results racer")
    assert_equal("2", women_road_bar.results[1].place, "Senior Women Road BAR results place")
    assert_equal(1, women_road_bar.results[1].points, "Senior Women Road BAR results points")
    assert_equal(1, women_road_bar.results[1].scores.size, "Molly Women Road BAR results scores")
    
    track_bar = bar.standings.detect {|standings| standings.name == 'Track'}
    assert_not_nil(track_bar, 'Track BAR')
    sr_men_track = track_bar.races.detect {|r| r.category.name == 'Senior Men'}
    assert_not_nil(sr_men_track, 'Senior Men Track BAR')
    tonkin_track_bar_result = sr_men_track.results.detect {|result| result.racer == racers(:tonkin)}
    assert_not_nil(tonkin_track_bar_result, 'Tonkin Track BAR result')
    assert_in_delta(22, tonkin_track_bar_result.points, 0.0, 'Tonkin Track BAR points')
  end
  
  def test_recalculate_tandem
    tandem = Category.find_or_create_by_name("Tandem")
    crit_discipline = disciplines(:criterium)
    crit_discipline.bar_categories << tandem
    crit_discipline.save!
    crit_discipline.reload
    assert(crit_discipline.bar_categories.include?(tandem), 'Criterium Discipline should include Tandem category')
    swan_island = SingleDayEvent.create({
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    })
    swan_island_standings = swan_island.standings.create(:event => swan_island)
    swan_island_tandem = swan_island_standings.races.create(:category => tandem)
    first_racers = Racer.new(:first_name => 'Scott/Cheryl', :last_name => 'Willson/Willson', :member_from => Date.new(2004, 1, 1))
    gentle_lovers = teams(:gentle_lovers)
    swan_island_tandem.results.create({
      :place => 12,
      :racer => first_racers,
      :team => gentle_lovers
    })
    # Existing racers
    second_racers = Racer.create(:first_name => 'Tim/John', :last_name => 'Johnson/Verhul', :member_from => Date.new(2004, 1, 1))
    second_racers_team = Team.create(:name => 'Kona/Northampton Cycling Club')
    swan_island_tandem.results.create({
      :place => 2,
      :racer => second_racers,
      :team => second_racers_team
    })

    Bar.recalculate(2004)
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Bar after recalculate")

    crit_bar = bar.standings.detect do |standings|
      standings.name == 'Criterium'
    end
    
    crit_tandem_bar = crit_bar.races.detect do |race|
      race.name == 'Tandem'
    end

    assert_not_nil(crit_tandem_bar, 'Criterium Tandem BAR')
    assert_equal(2, crit_tandem_bar.results.size, 'Criterium Tandem BAR results')
  end
  
  def test_standings_discipline
    mt_hood_1 = events(:mt_hood_1)
    tt_stage = mt_hood_1.standings.create(:name => 'Rowena Time Trial', :event => mt_hood_1, :discipline => 'Time Trial')
    womens_tt = tt_stage.races.create(:standings => tt_stage, :category => categories(:senior_women), :field_size => 6)
    leah = Racer.create(:name => 'Leah Goodchek', :member_from => Date.new(2005, 1, 1))
    womens_tt.results.create(:racer => leah, :place => '3')
    
    road_stage = mt_hood_1.standings.create(:name => 'Cooper Spur RR', :event => mt_hood_1)
    senior_men_road_stage = road_stage.races.create(:standings => road_stage, :category => categories(:sr_p_1_2))
    tuft = Racer.create(:name => 'Svein Tuft', :member_from => Date.new(2005, 1, 1))
    senior_men_road_stage.results.create(:racer => tuft, :place => '2')
    
    mt_hood_2 = events(:mt_hood_2)
    womens_road_stage = mt_hood_2.standings.create(:name => 'Womens Cooper Spur RR', :event => mt_hood_2, :discipline => 'Road')
    senior_women_road_stage = road_stage.races.create(:standings => womens_road_stage, :category => categories(:senior_women))
    senior_women_road_stage.results.create(:racer => leah, :place => '15')
    
    Bar.recalculate(2005)
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2005)])

    standings = bar.standings.detect{|standings| standings.name == 'Time Trial'}
    race = standings.races.detect {|race| race.category == categories(:senior_women)}
    leah_tt_bar_result = race.results.detect {|result| result.racer == leah}
    assert_equal(22, leah_tt_bar_result.points, 'Leah TT BAR points')

    leah_road_bar_result = bar.standings.detect{|s| s.name == 'Road'}.races.detect {|r| r.category == categories(:senior_women)}.results.detect {|r| r.racer == leah}
    assert_equal(1, leah_road_bar_result.points, 'Leah Road BAR points')

    svein_road_bar_result = bar.standings.detect{|s| s.name == 'Road'}.races.detect {|r| r.category == categories(:senior_men)}.results.detect {|r| r.racer == tuft}
    assert_equal(25, svein_road_bar_result.points, 'Svein Road BAR points')  
  end
  
  def test_combined_mtb_standings
    original_results_count = Result.count
    event = SingleDayEvent.create(:name => 'Reheers', :discipline => 'Mountain Bike')
    event.disable_notification!
    assert(event.errors.empty?, event.errors.full_messages)
    standings = event.standings.create

    pro_semi_pro_men = categories(:pro_semi_pro_men)
    pro_men = Category.find_or_create_by_name('Pro Men')
    race = standings.races.create(:category => pro_men)
    tonkin = racers(:tonkin)
    tonkin_result = race.results.create(:place => '1', :racer => tonkin, :time_s => '2:12:34')
    larsen = Racer.create(:name => 'Steve Larsen')
    larsen_result = race.results.create(:place => '2', :racer => larsen, :time_s => '2:13:00')
    decker = Racer.create(:name => 'Carl Decker')
    decker_result = race.results.create(:place => '3', :racer => decker, :time_s => '2:18:59')

    semi_pro_men = Category.find_or_create_by_name('Semi-Pro Men')
    race = standings.races.create(:category => semi_pro_men)
    brandt = Racer.create(:name => 'Chris Brandt')
    brandt_result = race.results.create(:place => '1', :racer => brandt, :time_s => '2:13:01')
    bear = Racer.create(:name => 'Bear Perrin')
    bear_result = race.results.create(:place => '2', :racer => bear, :time_s => '2:14:15')
    chad = Racer.create(:name => 'Chad Swanson')
    chad_result = race.results.create(:place => '3', :racer => chad, :time_s => '2:32:00')

    expert_men = Category.find_or_create_by_name('Expert Men')
    race = standings.races.create(:standings => standings, :category => expert_men)
    weaver = racers(:weaver)
    weaver_result = race.results.create(:place => '1', :racer => weaver, :time_s => '2:15:56')
    mahoney = Racer.create(:name => 'Matt Mahoney')
    mahoney_result = race.results.create(:place => '2', :racer => mahoney, :time_s => '2:33:11')
    sam = Racer.create(:name => 'Sam Richardson')
    sam_result = race.results.create(:place => '3', :racer => sam, :time_s => '3:01:19')

    pro_expert_women = categories(:pro_expert_women)
    pro_women = Category.find_or_create_by_name('Pro Women')
    race = standings.races.create(:standings => standings, :category => pro_women)
    molly = racers(:molly)
    molly_result = race.results.create(:place => '1', :racer => molly, :time_s => '1:41:37')
    alice = racers(:alice)
    alice_result = race.results.create(:place => '2', :racer => alice, :time_s => '1:43:55')
    rita = Racer.create(:name => 'Rita Metermaid')
    rita_result = race.results.create(:place => '3', :racer => rita, :time_s => '2:13:33')

    expert_women = Category.find_or_create_by_name('Expert Women')
    race = standings.races.create(:category => expert_women)
    expert_woman_1 = Racer.create(:name => 'Expert Woman 1')
    expert_woman_1_result = race.results.create(:place => '1', :racer => expert_woman_1, :time_s => '1:00:00')
    expert_woman_2 = Racer.create(:name => 'Expert Woman 2')
    expert_woman_2_result = race.results.create(:place => '2', :racer => expert_woman_2, :time_s => '2:00:00')
    expert_woman_3 = Racer.create(:name => 'Expert Woman 3')
    expert_woman_3_result = race.results.create(:place => '3', :racer => expert_woman_3, :time_s => '3:03:03')

    sport_women = Category.find_or_create_by_name('Sport Women')
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
    assert_not_nil(combined_standings, 'Combined Pro, Semi-Pro, Expert standings')
    assert_equal(2, combined_standings.races.size, 'Combined Standings races')

    mens_combined = combined_standings.races.detect {|race| race.category == categories(:pro_semi_pro_men)}
    assert_not_nil(mens_combined, "Mens combined race")
    expected = [
      tonkin_result,
      larsen_result,
      brandt_result,
      bear_result,
      decker_result,
      chad_result,
    ]
    assert_results(expected, mens_combined.results(true), mens_combined.name)
    assert_equal(1, mens_combined.bar_points, 'Mens combined BAR points')
    original_standings = event.standings.detect {|standings| !standings.name['Combined']}
    for race in original_standings.races
      if race.category == pro_semi_pro_men || race.category == pro_expert_women
        assert_equal(0, race.bar_points, 'Original pro and semi-pro races BAR points')
      end
    end

    women_combined = combined_standings.races.detect {|race| race.category == categories(:pro_expert_women)}
    assert_not_nil(women_combined, "Women combined race")
    expected = [
      expert_woman_1_result,
      molly_result,
      alice_result,
      expert_woman_2_result,
      rita_result,
      expert_woman_3_result
    ]
    assert_results(expected, women_combined.results(true))
    assert_equal(1, women_combined.bar_points, 'Women combined BAR points')

    # recreate -- should be same
    combined_standings.recalculate
    event.reload
    assert_equal(2, event.standings.count, 'Event standings (results + combined standings)')
    combined_standings = event.standings.detect {|standings| standings.name['Combined']}
    assert_not_nil(combined_standings, 'Combined Pro, Semi-Pro standings')
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
    assert_equal(original_results_count, results_after_bar_recalc.size, 'Should have no new results')
  end
  
  # Used to only award bonus points for races of five or less, but now all races get equal points
  def test_field_size
    for racer in Racer.find(:all)
      racer.member_to = Date.new(2009, 12, 31)
      racer.save!
    end
    cross_crusade = Series.create!(:name => "Cross Crusade")

    # Large event
    barton = SingleDayEvent.create!({
      :name => "Cross Crusade: Barton Park",
      :discipline => "Cyclocross",
      :date => Date.new(2009, 11, 7),
      :parent => cross_crusade
    })
    barton_standings = barton.standings.create
    men_a = Category.find_by_name("Men A")
    barton_a = barton_standings.races.create(:category => men_a)
    barton_a.results.create({
      :place => 3,
      :racer => racers(:tonkin)
    })
    barton_a.results.create({
      :place => 15,
      :racer => racers(:weaver)
    })
    barton_a.field_size = 75
    barton_a.save!

    # Smaller event
    estacada = SingleDayEvent.create!({
      :name => "Cross Crusade: Estacada",
      :discipline => "Cyclocross",
      :date => Date.new(2009, 11, 14),
      :parent => cross_crusade
    })
    estacada_standings = estacada.standings.create
    estacada_a = estacada_standings.races.create(:category => men_a)
    estacada_a.results.create({
      :place => 1,
      :racer => racers(:tonkin)
    })
    estacada_a.results.create({
      :place => 8,
      :racer => racers(:weaver)
    })
    estacada_a.field_size = 74
    estacada_a.save!

    # Large "national" event
    alpenrose = SingleDayEvent.create!({
      :name => "Cross Crusade: alpenrose",
      :discipline => "Cyclocross",
      :date => Date.new(2009, 11, 14),
      :parent => cross_crusade
    })
    alpenrose_standings = alpenrose.standings.create
    alpenrose_standings.bar_points = 3
    alpenrose_standings.save!
    alpenrose_a = alpenrose_standings.races.create(:category => men_a)
    alpenrose_a.results.create({
      :place => 10,
      :racer => racers(:tonkin)
    })
    alpenrose_a.field_size = 75
    alpenrose_a.save!

    # Too small event
    dfl = SingleDayEvent.create!({
      :name => "dfL Outlaw Race",
      :discipline => "Cyclocross",
      :date => Date.new(2009, 9, 3)
    })
    dfl_standings = dfl.standings.create
    dfl_a = dfl_standings.races.create(:category => men_a)
    dfl_a.results.create({
      :place => 2,
      :racer => racers(:tonkin)
    })
    dfl_a.results.create({
      :place => 3,
      :racer => racers(:weaver)
    })
    dfl_a.field_size = 4
    dfl_a.save!

    # Too small event in other discipline
    ice_breaker = SingleDayEvent.create!({
      :name => "Ice Breaker",
      :discipline => "Criterium",
      :date => Date.new(2009, 2, 21)
    })
    ice_breaker_standings = ice_breaker.standings.create
    ice_breaker_a = ice_breaker_standings.races.create(:category => categories(:sr_p_1_2))
    ice_breaker_a.results.create({
      :place => 14,
      :racer => racers(:tonkin)
    })
    ice_breaker_a.field_size = 4
    ice_breaker_a.save!

    Bar.recalculate(2009)
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2009)])
    
    cx_bar = bar.standings.detect do |standings|
      standings.name == 'Cyclocross'
    end
    
    men_a_bar = cx_bar.races.detect do |race|
      race.name == 'Men A'
    end
    
    assert_not_nil(men_a_bar, 'Men A Cyclocross BAR')
    assert_equal(2, men_a_bar.results.size, 'Men A Cyclocross BAR results')

    men_a_bar.results.sort!
    tonkin_bar_result = men_a_bar.results.first
    assert_equal(racers(:tonkin), tonkin_bar_result.racer)
    assert_equal(33 + 30 + 25 + 21, tonkin_bar_result.points, 'Tonkin BAR points')
    weaver_bar_result = men_a_bar.results.last
    assert_equal(racers(:weaver), weaver_bar_result.racer)
    assert_equal(1.5 + 11 + 22, weaver_bar_result.points, 'Weaver BAR points')

    crit_bar = bar.standings.detect do |standings|
      standings.name == 'Criterium'
    end
    
    sr_men_crit_bar = crit_bar.races.detect do |race|
      race.name == 'Senior Men'
    end
    
    assert_not_nil(sr_men_crit_bar, 'Senior Men Crit BAR')
    assert_equal(1, sr_men_crit_bar.results.size, 'Senior Men Crit BAR results')

    tonkin_bar_result = sr_men_crit_bar.results.first
    assert_equal(racers(:tonkin), tonkin_bar_result.racer)
    assert_equal(2, tonkin_bar_result.points, 'Tonkin Crit BAR points')
  end
  
  def test_previous_year
    weaver = racers(:weaver)
    previous_year = Date.today.year - 1
    weaver.member_from = Date.new(previous_year, 1, 1)
    current_year = Date.today.year - 1
    weaver.member_to = Date.new(current_year, 12, 31)
    weaver.save!
    
    # Create result for previous year
    previous_year_event = SingleDayEvent.create(:date => Date.new(previous_year, 4, 19), :discipline => 'Road')
    previous_year_event.reload
    assert_equal('Road', previous_year_event.discipline, 'Event discipline')
    previous_year_result = previous_year_event.standings.create.races.create(:category => categories(:sr_p_1_2)).results.create(:place => '3', :racer => weaver)
    standings = previous_year_event.standings(true)
    assert_equal(1, standings.size, 'Standings size')
    assert_equal(previous_year, standings.first.date.year, 'Standings year')
    assert_equal('Road', standings.first.discipline, 'Standings discipline')
    assert_equal(1, standings.first.bar_points, 'BAR points')
    assert_equal(1, standings.first.races(true).size, 'Races size')
    assert_equal(categories(:sr_p_1_2), standings.first.races(true).first.category, 'Category')
    assert_not_nil(standings.first.races(true).first.category.parent, 'Parent Category')
    
    # Calculate previous years' BAR
    Bar.recalculate(previous_year)
    previous_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    
    # Assert it has results
    previous_year_road_bar = previous_year_bar.standings.detect do |standings|
      standings.name == 'Road'
    end
    previous_year_sr_men_road_bar = previous_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_road_bar.results.empty?, 'Previous year BAR should have results')
    
    # Create result for this year
    current_year_event = SingleDayEvent.create(:date => Date.new(current_year, 7, 20), :discipline => 'Road')
    current_year_event.reload
    assert_equal('Road', current_year_event.discipline, 'Event discipline')
    current_year_result = current_year_event.standings.create.races.create(:category => categories(:sr_p_1_2)).results.create(:place => '13', :racer => weaver)

    # Calculate this years' BAR
    Bar.recalculate(current_year)

    # Assert both BARs have results
    previous_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    previous_year_road_bar = previous_year_bar.standings.detect do |standings|
      standings.name == 'Road'
    end
    previous_year_sr_men_road_bar = previous_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_road_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(current_year, 1, 1)])
    current_year_road_bar = current_year_bar.standings.detect do |standings|
      standings.name == 'Road'
    end
    current_year_sr_men_road_bar = current_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!current_year_sr_men_road_bar.results.empty?, 'Current year BAR should have results')

    # Recalc both BARs
    Bar.recalculate(previous_year)
    Bar.recalculate(current_year)

    # Assert both BARs have results
    previous_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    previous_year_road_bar = previous_year_bar.standings.detect do |standings|
      standings.name == 'Road'
    end
    previous_year_sr_men_road_bar = previous_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_road_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(current_year, 1, 1)])
    current_year_road_bar = current_year_bar.standings.detect do |standings|
      standings.name == 'Road'
    end
    current_year_sr_men_road_bar = current_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!current_year_sr_men_road_bar.results.empty?, 'Current year BAR should have results')
  end
  
  def test_weekly_series_overall
    weaver = racers(:weaver)
    event = WeeklySeries.create(:discipline => 'Circuit')
    # Need a SingleDayEvent to hold a date in the past
    event.events.create(:date => Date.new(1999, 5, 8))
    race = event.standings.create.races.create(:category => categories(:senior_men))
    race.results.create(:racer => weaver, :place => 4)
    Bar.recalculate(1999)
    bar = Bar.find(:first)
    standings = bar.standings.detect {|s| s.name == 'Road'}
    race = standings.races.detect {|r| r.name == 'Senior Men'}
    assert_equal(1, race.results.size, 'Results')
    assert_equal(19, race.results.first.points, 'BAR result points')
  end
  
  def test_points_for_team_event
    event = SingleDayEvent.new
    standings = Standings.new(:bar_points => 2, :event => event)
    standings.name = 'Standings'
    race = Race.new(:standings => standings, :category => categories(:senior_men))
    result = Result.new(:race => race, :place => 4)
    competition = Bar.new
    team_size = 3
    points = competition.points_for(result, team_size)
    assert_in_delta(12.666, points, 0.001, 'Points for first place with team of 3 and multiplier of 2')

    event = SingleDayEvent.new
    standings = Standings.new(:bar_points => 3, :event => event)
    standings.name = 'Standings'
    race = Race.new(:standings => standings, :category => categories(:senior_men))
    result = Result.new(:race => race, :place => 4)
    competition = Bar.new
    team_size = 2
    points = competition.points_for(result, team_size)
    assert_in_delta(28.5, points, 0.001, 'Points for third place with team of 2 and multiplier of 3')
  end

  def test_count_category_4_5_results
    category_4_5_men = categories(:men_4_5)
    category_4_men = categories(:category_4_men)
    category_5_men = categories(:category_5_men)

    standings = SingleDayEvent.create!(:discipline => 'Road').standings.create!
    cat_4_5_race = standings.races.create!(:category => category_4_5_men)
    weaver = racers(:weaver)
    cat_4_5_race.results.create!(:place => '4', :racer => weaver)
    
    Bar.recalculate
    
    current_year = Date.today.year
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(current_year, 1, 1)])
    road_bar_standings = bar.standings.detect { |standings| standings.discipline == "Road" }
    cat_4_road_bar = road_bar_standings.races.detect { |race| race.category == category_4_men }
    assert_equal(1, cat_4_road_bar.results.size, "Cat 4 Overall BAR results")
    cat_5_road_bar = road_bar_standings.races.detect { |race| race.category == category_5_men }
    assert_equal(0, cat_5_road_bar.results.size, "Cat 5 Overall BAR results")
    
    weaver_result = cat_4_road_bar.results.detect { |result| result.racer == weaver }
    assert_equal("1", weaver_result.place, "Weaver Cat 4/5 Overall BAR place")
    assert_equal(1, weaver_result.scores.size, "Weaver Cat 4/5 Overall BAR 1st place scores")
  end
end