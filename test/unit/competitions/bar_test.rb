# There is duplication between BAR tests, but refactring the tests should wait until the Competition refactoring is complete
# FIXME Assert correct team names on BAR results

require "test_helper"

class BarTest < ActiveSupport::TestCase
  def test_create
    date = Date.new(2006)
    bar = Bar.create!(
      :name => "#{date.year} Track BAR",
      :date => date,
      :discipline => Discipline[:track].name
    )
    assert_equal(2006, bar.year, "New BAR year")
  end
  
  def test_calculate
    # Lot of set-up for BAR. Keep it out of fixtures and do one-time here.
    
    cross_crusade = Series.create!(:name => "Cross Crusade")
    barton = SingleDayEvent.create!({
      :name => "Cross Crusade: Barton Park",
      :discipline => "Cyclocross",
      :date => Date.new(2004, 11, 7),
      :parent => cross_crusade
    })
    men_a = Category.find_by_name("Men A")
    barton_a = barton.races.create(:category => men_a, :field_size => 5)
    barton_a.results.create({
      :place => 3,
      :person => people(:tonkin)
    })
    barton_a.results.create({
      :place => 15,
      :person => people(:weaver)
    })
    barton_a.results.create({
      :place => 2,
      :person => people(:alice),
      :bar => false
    })
    
    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    })
    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    swan_island_senior_men = swan_island.races.create(:category => senior_men, :field_size => 4)
    swan_island_senior_men.results.create({
      :place => 12,
      :person => people(:tonkin)
    })
    swan_island_senior_men.results.create({
      :place => 2,
      :person => people(:molly)
    })
    senior_women = Category.find_by_name("Senior Women")
    senior_women_swan_island = swan_island.races.create(:category => senior_women, :field_size => 3)
    senior_women_swan_island.results.create({
      :place => 1,
      :person => people(:molly)
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
    thursday_track_senior_men = thursday_track.races.create(:category => senior_men, :field_size => 6)
    r = thursday_track_senior_men.results.create(
      :place => 5,
      :person => people(:weaver)
    )
    thursday_track_senior_men.results.create(
      :place => 14,
      :person => people(:tonkin),
      :team => teams(:kona)
    )
    
    team_track = SingleDayEvent.create!({
      :name => "Team Track State Championships",
      :discipline => "Track",
      :date => Date.new(2004, 9, 1)
    })
    team_track.bar_points = 2
    team_track.save!
    team_track_senior_men = team_track.races.create(:category => senior_men, :field_size => 6)
    team_track_senior_men.results.create({
      :place => 1,
      :person => people(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create({
      :place => 1,
      :person => people(:tonkin),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create({
      :place => 1,
      :person => people(:molly)
    })
    team_track_senior_men.results.create({
      :place => 5,
      :person => people(:alice)
    })
    team_track_senior_men.results.create({
      :place => 5,
      :person => people(:matson)
    })
    # Weaver and Erik's second ride should not count
    team_track_senior_men.results.create({
      :place => 15,
      :person => people(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create({
      :place => 15,
      :person => people(:tonkin),
      :team => teams(:kona)
    })
    
    larch_mt_hillclimb = SingleDayEvent.create!({
      :name => "Larch Mountain Hillclimb",
      :discipline => "Time Trial",
      :date => Date.new(2004, 2, 1)
    })
    larch_mt_hillclimb_senior_men = larch_mt_hillclimb.races.create(:category => senior_men, :field_size => 6)
    larch_mt_hillclimb_senior_men.results.create({
      :place => 13,
      :person => people(:tonkin),
      :team => teams(:kona)
    })
  
    results_baseline_count = Result.count
    assert_equal(0, Bar.count, "Bar before calculate!")
    original_results_count = Result.count
    Bar.calculate!(2004)
    assert_equal(7, Bar.count(:conditions => ['date = ?', Date.new(2004)]), "Bar events after calculate!")
    assert_equal(original_results_count + 15, Result.count, "Total count of results in DB")
    # Should delete old BAR
    Bar.calculate!(2004)
    assert_equal(7, Bar.count(:conditions => ['date = ?', Date.new(2004)]), "Bar events after calculate!")
    Bar.find(:all, :conditions => ['date = ?', Date.new(2004)]).each do |bar|
      assert(bar.name[/2004.*BAR/], "Name #{bar.name} is wrong")
      assert_equal_dates(Date.today, bar.updated_at, "BAR last updated")
    end
    assert_equal(original_results_count + 15, Result.count, "Total count of results in DB")
    
    road_bar = Bar.find_by_name("2004 Road BAR")
    women_road_bar = road_bar.races.detect {|b| b.name == "Senior Women" }
    assert_equal(categories(:senior_women), women_road_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(2, women_road_bar.results.size, "Senior Women Road BAR results")

    women_road_bar.results.sort!
    assert_equal(people(:alice), women_road_bar.results[0].person, "Senior Women Road BAR results person")
    assert_equal("1", women_road_bar.results[0].place, "Senior Women Road BAR results place")
    assert_equal(25, women_road_bar.results[0].points, "Senior Women Road BAR results points")

    assert_equal(people(:molly), women_road_bar.results[1].person, "Senior Women Road BAR results person")
    assert_equal("2", women_road_bar.results[1].place, "Senior Women Road BAR results place")
    assert_equal(1, women_road_bar.results[1].points, "Senior Women Road BAR results points")
    assert_equal(1, women_road_bar.results[1].scores.size, "Molly Women Road BAR results scores")
    
    track_bar = Bar.find_by_name("2004 Track BAR")
    assert_not_nil(track_bar, 'Track BAR')
    sr_men_track = track_bar.races.detect {|r| r.category.name == 'Senior Men'}
    assert_not_nil(sr_men_track, 'Senior Men Track BAR')
    tonkin_track_bar_result = sr_men_track.results.detect {|result| result.person == people(:tonkin)}
    assert_not_nil(tonkin_track_bar_result, 'Tonkin Track BAR result')
    assert_in_delta(22, tonkin_track_bar_result.points, 0.0, 'Tonkin Track BAR points')
  end
  
  def test_calculate_tandem
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
    swan_island_tandem = swan_island.races.create(:category => tandem)
    first_people = Person.new(:first_name => 'Scott/Cheryl', :last_name => 'Willson/Willson', :member_from => Date.new(2004))
    gentle_lovers = teams(:gentle_lovers)
    swan_island_tandem.results.create({
      :place => 12,
      :person => first_people,
      :team => gentle_lovers
    })
    # Existing people
    second_people = Person.create(:first_name => 'Tim/John', :last_name => 'Johnson/Verhul', :member_from => Date.new(2004))
    second_people_team = Team.create(:name => 'Kona/Northampton Cycling Club')
    swan_island_tandem.results.create({
      :place => 2,
      :person => second_people,
      :team => second_people_team
    })

    Bar.calculate!(2004)

    crit_bar = Bar.find_by_year_and_discipline(2004, "Criterium")
    crit_tandem_bar = crit_bar.races.detect do |race|
      race.name == 'Tandem'
    end

    assert_not_nil(crit_tandem_bar, 'Criterium Tandem BAR')
    assert_equal(2, crit_tandem_bar.results.size, 'Criterium Tandem BAR results')
  end
  
  def test_discipline
    mt_hood_1 = events(:mt_hood_1)
    tt_stage = mt_hood_1.children.create!(:name => 'Rowena Time Trial', :discipline => 'Time Trial')
    womens_tt = tt_stage.races.create!(:category => categories(:senior_women), :field_size => 6)
    leah = Person.create!(:name => 'Leah Goodchek', :member_from => Date.new(2005, 1, 1))
    womens_tt.results.create!(:person => leah, :place => '3')
    
    road_stage = mt_hood_1.children.create!(:name => 'Cooper Spur RR')
    senior_men_road_stage = road_stage.races.create!(:category => categories(:sr_p_1_2))
    tuft = Person.create(:name => 'Svein Tuft', :member_from => Date.new(2005, 1, 1))
    senior_men_road_stage.results.create!(:person => tuft, :place => '2')
    
    mt_hood_2 = events(:mt_hood_2)
    womens_road_stage = mt_hood_2.children.create!(:name => 'Womens Cooper Spur RR', :discipline => 'Road')
    senior_women_road_stage = road_stage.races.create!(:category => categories(:senior_women))
    senior_women_road_stage.results.create!(:person => leah, :place => '15')
    
    Bar.calculate!(2005)

    event = Bar.find_by_year_and_discipline(2005, "Time Trial")
    race = event.races.detect {|race| race.category == categories(:senior_women)}
    leah_tt_bar_result = race.results.detect {|result| result.person == leah}
    assert_equal(22, leah_tt_bar_result.points, 'Leah TT BAR points')

    road_bar = Bar.find_by_year_and_discipline(2005, "Road")
    leah_road_bar_result = road_bar.races.detect {|r| r.category == categories(:senior_women)}.results.detect {|r| r.person == leah}
    assert_equal(1, leah_road_bar_result.points, 'Leah Road BAR points')

    svein_road_bar_result = road_bar.races.detect {|r| r.category == categories(:senior_men)}.results.detect {|r| r.person == tuft}
    assert_equal(25, svein_road_bar_result.points, 'Svein Road BAR points')  
  end
  
  # Used to only award bonus points for races of five or less, but now all races get equal points
  def test_field_size
    for person in Person.find(:all)
      person.member_to = Date.new(2009, 12, 31)
      person.save!
    end
    cross_crusade = Series.create!(:name => "Cross Crusade")

    # Large event
    barton = SingleDayEvent.create!({
      :name => "Cross Crusade: Barton Park",
      :discipline => "Cyclocross",
      :date => Date.new(2009, 11, 7),
      :parent => cross_crusade
    })
    men_a = Category.find_by_name("Men A")
    barton_a = barton.races.create(:category => men_a)
    barton_a.results.create({
      :place => 3,
      :person => people(:tonkin)
    })
    barton_a.results.create({
      :place => 15,
      :person => people(:weaver)
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
    estacada_a = estacada.races.create(:category => men_a)
    estacada_a.results.create({
      :place => 1,
      :person => people(:tonkin)
    })
    estacada_a.results.create({
      :place => 8,
      :person => people(:weaver)
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
    alpenrose.bar_points = 3
    alpenrose.save!
    alpenrose_a = alpenrose.races.create(:category => men_a)
    alpenrose_a.results.create({
      :place => 10,
      :person => people(:tonkin)
    })
    alpenrose_a.field_size = 75
    alpenrose_a.save!

    # Too small event
    dfl = SingleDayEvent.create!({
      :name => "dfL Outlaw Race",
      :discipline => "Cyclocross",
      :date => Date.new(2009, 9, 3)
    })
    dfl_a = dfl.races.create(:category => men_a)
    dfl_a.results.create({
      :place => 2,
      :person => people(:tonkin)
    })
    dfl_a.results.create({
      :place => 3,
      :person => people(:weaver)
    })
    dfl_a.field_size = 4
    dfl_a.save!

    # Too small event in other discipline
    ice_breaker = SingleDayEvent.create!({
      :name => "Ice Breaker",
      :discipline => "Criterium",
      :date => Date.new(2009, 2, 21)
    })
    ice_breaker_a = ice_breaker.races.create(:category => categories(:sr_p_1_2))
    ice_breaker_a.results.create({
      :place => 14,
      :person => people(:tonkin)
    })
    ice_breaker_a.field_size = 4
    ice_breaker_a.save!

    Bar.calculate!(2009)
    
    cx_bar = Bar.find_by_year_and_discipline(2009, "Cyclocross")
    men_a_bar = cx_bar.races.detect { |race| race.name == 'Men A' }
    
    assert_not_nil(men_a_bar, 'Men A Cyclocross BAR')
    assert_equal(2, men_a_bar.results.size, 'Men A Cyclocross BAR results')

    men_a_bar.results.sort!
    tonkin_bar_result = men_a_bar.results.first
    assert_equal(people(:tonkin), tonkin_bar_result.person)
    assert_equal(33 + 30 + 25 + 21, tonkin_bar_result.points, 'Tonkin BAR points')
    weaver_bar_result = men_a_bar.results.last
    assert_equal(people(:weaver), weaver_bar_result.person)
    assert_equal(1.5 + 11 + 22, weaver_bar_result.points, 'Weaver BAR points')

    crit_bar = Bar.find_by_year_and_discipline(2009, "Criterium")
    sr_men_crit_bar = crit_bar.races.detect { |race| race.name == 'Senior Men' }
    
    assert_not_nil(sr_men_crit_bar, 'Senior Men Crit BAR')
    assert_equal(1, sr_men_crit_bar.results.size, 'Senior Men Crit BAR results')

    tonkin_bar_result = sr_men_crit_bar.results.first
    assert_equal(people(:tonkin), tonkin_bar_result.person)
    assert_equal(2, tonkin_bar_result.points, 'Tonkin Crit BAR points')
  end
  
  def test_previous_year
    weaver = people(:weaver)
    previous_year = Date.today.year - 1
    weaver.member_from = Date.new(previous_year, 1, 1)
    current_year = Date.today.year - 1
    weaver.member_to = Date.new(current_year, 12, 31)
    weaver.save!
    
    # Create result for previous year
    previous_year_event = SingleDayEvent.create(:date => Date.new(previous_year, 4, 19), :discipline => 'Road')
    previous_year_event.reload
    assert_equal('Road', previous_year_event.discipline, 'Event discipline')
    previous_year_result = previous_year_event.races.create(:category => categories(:sr_p_1_2)).results.create(:place => '3', :person => weaver)
    assert_equal('Road', previous_year_event.discipline, 'Previous year event discipline')
    assert_equal(1, previous_year_event.bar_points, 'BAR points')
    assert_equal(1, previous_year_event.races(true).size, 'Races size')
    assert_equal(categories(:sr_p_1_2), previous_year_event.races(true).first.category, 'Category')
    assert_not_nil(previous_year_event.races(true).first.category.parent, 'Parent Category')
    
    # Calculate previous years' BAR
    Bar.calculate!(previous_year)
    previous_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    
    # Assert it has results
    previous_year_road_bar = Bar.find_by_year_and_discipline(previous_year, "Road")
    previous_year_sr_men_road_bar = previous_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_road_bar.results.empty?, 'Previous year BAR should have results')
    
    # Create result for this year
    current_year_event = SingleDayEvent.create(:date => Date.new(current_year, 7, 20), :discipline => 'Road')
    current_year_event.reload
    assert_equal('Road', current_year_event.discipline, 'Event discipline')
    current_year_result = current_year_event.races.create(:category => categories(:sr_p_1_2)).results.create(:place => '13', :person => weaver)

    # Calculate this years' BAR
    Bar.calculate!(current_year)

    # Assert both BARs have results
    previous_year_road_bar = Bar.find_by_year_and_discipline(previous_year, "Road")
    previous_year_sr_men_road_bar = previous_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_road_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_road_bar = Bar.find_by_year_and_discipline(current_year, "Road")
    current_year_sr_men_road_bar = current_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!current_year_sr_men_road_bar.results.empty?, 'Current year BAR should have results')

    # Recalc both BARs
    Bar.calculate!(previous_year)
    Bar.calculate!(current_year)

    # Assert both BARs have results
    previous_year_road_bar = Bar.find_by_year_and_discipline(previous_year, "Road")
    previous_year_sr_men_road_bar = previous_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_road_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_road_bar = Bar.find_by_year_and_discipline(current_year, "Road")
    current_year_sr_men_road_bar = current_year_road_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!current_year_sr_men_road_bar.results.empty?, 'Current year BAR should have results')
  end
  
  def test_weekly_series_overall
    weaver = people(:weaver)
    event = WeeklySeries.create!(:discipline => 'Circuit')
    # Need a SingleDayEvent to hold a date in the past
    event.children.create!(:date => Date.new(1999, 5, 8))
    race = event.races.create(:category => categories(:senior_men))
    race.results.create(:person => weaver, :place => 4)
    Bar.calculate!(1999)
    bar = Bar.find_by_year_and_discipline(1999, "Road")
    race = bar.races.detect {|r| r.name == 'Senior Men'}
    assert_equal(1, race.results.size, 'Results')
    assert_equal(19, race.results.first.points, 'BAR result points')
  end
  
  def test_points_for_team_event
    event = SingleDayEvent.create!(:bar_points => 2)
    race = event.races.create!(:category => categories(:senior_men))
    result = race.results.create!(:place => 4)
    competition = Bar.new
    competition.set_defaults
    team_size = 3
    points = competition.points_for(result, team_size)
    assert_in_delta(12.666, points, 0.001, 'Points for first place with team of 3 and multiplier of 2')

    event = SingleDayEvent.create!(:bar_points => 3)
    race = event.races.create!(:category => categories(:senior_men))
    result = race.results.create!(:place => 4)
    competition = Bar.new
    competition.set_defaults
    team_size = 2
    points = competition.points_for(result, team_size)
    assert_in_delta(28.5, points, 0.001, 'Points for third place with team of 2 and multiplier of 3')
  end

  def test_count_category_4_5_results
    category_4_5_men = categories(:men_4_5)
    category_4_men = categories(:category_4_men)
    category_5_men = categories(:category_5_men)

    event = SingleDayEvent.create!(:discipline => 'Road')
    cat_4_5_race = event.races.create!(:category => category_4_5_men)
    weaver = people(:weaver)
    cat_4_5_race.results.create!(:place => '4', :person => weaver)
    
    Bar.calculate!
    
    current_year = Date.today.year
    road_bar = Bar.find_by_year_and_discipline(current_year, "Road")
    cat_4_road_bar = road_bar.races.detect { |race| race.category == category_4_men }
    assert_equal(1, cat_4_road_bar.results.size, "Cat 4 Overall BAR results")
    cat_5_road_bar = road_bar.races.detect { |race| race.category == category_5_men }
    assert_equal(0, cat_5_road_bar.results.size, "Cat 5 Overall BAR results")
    
    weaver_result = cat_4_road_bar.results.detect { |result| result.person == weaver }
    assert_equal("1", weaver_result.place, "Weaver Cat 4/5 Overall BAR place")
    assert_equal(1, weaver_result.scores.size, "Weaver Cat 4/5 Overall BAR 1st place scores")
  end
end