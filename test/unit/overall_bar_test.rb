# There is duplication between BAR tests, but refactring the tests should wait until the Competition refactoring is complete

require File.dirname(__FILE__) + '/../test_helper'

class OverallBarTest < ActiveSupport::TestCase
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
    barton_a = barton_standings.races.create!(:category => men_a, :field_size => 5)
    barton_a.results.create!({
      :place => 3,
      :racer => racers(:tonkin)
    })
    barton_a.results.create!({
      :place => 15,
      :racer => racers(:weaver)
    })
    
    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    })
    swan_island_standings = swan_island.standings.create
    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    swan_island_senior_men = swan_island_standings.races.create!(:category => senior_men, :field_size => 4)
    swan_island_senior_men.results.create!({
      :place => 12,
      :racer => racers(:tonkin)
    })
    swan_island_senior_men.results.create!({
      :place => 2,
      :racer => racers(:molly)
    })
    senior_women = Category.find_by_name("Senior Women")
    senior_women_swan_island = swan_island_standings.races.create!(:category => senior_women, :field_size => 3)
    senior_women_swan_island.results.create!({
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
    thursday_track_senior_men = thursday_track_standings.races.create!(:category => senior_men, :field_size => 6)
    r = thursday_track_senior_men.results.create!(
      :place => 5,
      :racer => racers(:weaver)
    )
    thursday_track_senior_men.results.create!(
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
    team_track_senior_men = team_track_standings.races.create!(:category => senior_men, :field_size => 6)
    team_track_senior_men.results.create!({
      :place => 1,
      :racer => racers(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create!({
      :place => 1,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create!({
      :place => 1,
      :racer => racers(:molly)
    })
    team_track_senior_men.results.create!({
      :place => 5,
      :racer => racers(:alice)
    })
    team_track_senior_men.results.create!({
      :place => 5,
      :racer => racers(:matson)
    })
    # Weaver and Erik's second ride should not count
    team_track_senior_men.results.create!({
      :place => 15,
      :racer => racers(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create!({
      :place => 15,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    })
    
    larch_mt_hillclimb = SingleDayEvent.create!({
      :name => "Larch Mountain Hillclimb",
      :discipline => "Time Trial",
      :date => Date.new(2004, 2, 1)
    })
    larch_mt_hillclimb_standings = larch_mt_hillclimb.standings.create!(:event => larch_mt_hillclimb)
    larch_mt_hillclimb_senior_men = larch_mt_hillclimb_standings.races.create!(:category => senior_men, :field_size => 6)
    larch_mt_hillclimb_senior_men.results.create!({
      :place => 13,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    })
      
    results_baseline_count = Result.count
    assert_equal(0, Bar.count, "Bar standings before recalculate")
    original_results_count = Result.count
    Bar.recalculate(2004)
    
    # Discipline BAR results past 300 don't count -- add fake result
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    sr_men_road_bar = bar.standings.detect {|s| s.name == 'Road'}.races.detect {|r| r.category == categories(:senior_men)}
    sr_men_road_bar.results.create!(:place => 305, :racer => racers(:alice))
    
    OverallBar.recalculate(2004)
    bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Bar after recalculate")
    assert_equal(1, OverallBar.count, "Bar events after recalculate")
    assert_equal(1, bar.standings.count, "Bar standings after recalculate")
    assert_equal(original_results_count + 23, Result.count, "Total count of results in DB")
    # Should delete old BAR
    OverallBar.recalculate(2004)
    assert_equal(1, OverallBar.count, "Bar events after recalculate")
    bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Bar after recalculate")
    assert_equal(1, bar.standings.count, "Bar standings after recalculate")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 Bar date")
    assert_equal("2004 Overall BAR", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "BAR last updated")
    assert_equal(original_results_count + 23, Result.count, "Total count of results in DB")

    overall_bar = bar.standings.detect do |standings|
      standings.name == '2004 Overall BAR'
    end

    assert_equal("2004 Overall BAR", overall_bar.name, "2004 Overall Bar name")
    assert_equal(12, overall_bar.races.size, "2004 Overall Bar races")
    assert_equal_dates(Date.today, overall_bar.updated_at, "BAR last updated")
    
    senior_men_overall_bar = overall_bar.races.detect do |b|
      b.name == "Senior Men"
    end
    
    assert_equal(categories(:senior_men), senior_men_overall_bar.category, "Senior Men BAR race BAR cat")
    assert_equal(5, senior_men_overall_bar.results.size, "Senior Men Overall BAR results")
    assert_equal_dates(Date.today, senior_men_overall_bar.updated_at, "BAR last updated")
    senior_men_overall_bar.results.sort!
    
    assert_equal(racers(:tonkin), senior_men_overall_bar.results[0].racer, "Senior Men Overall BAR results racer")
    assert_equal("1", senior_men_overall_bar.results[0].place, "Senior Men Overall BAR results place")
    assert_equal(1249, senior_men_overall_bar.results[0].points, "Tonkin Senior Men Overall BAR results points")
    assert_equal(5, senior_men_overall_bar.results[0].scores.size, "Tonkin Overall BAR results scores")
    scores = senior_men_overall_bar.results[0].scores.sort {|x, y| y.points <=> x.points}
    assert_equal(300, scores[0].points, "Tonkin overall BAR points for discipline 0")
    assert_equal(300, scores[1].points, "Tonkin overall BAR points for discipline 1")
    assert_equal(300, scores[2].points, "Tonkin overall BAR points for discipline 2")
    assert_equal(299, scores[3].points, "Tonkin overall BAR points for discipline 3")
    assert_equal(50, scores[4].points, "Tonkin overall BAR points for discipline 4")

    assert_equal(racers(:weaver), senior_men_overall_bar.results[1].racer, "Senior Men Overall BAR results racer")
    assert_equal("2", senior_men_overall_bar.results[1].place, "Senior Men Overall BAR results place")
    assert_equal(898, senior_men_overall_bar.results[1].points, "Senior Men Overall BAR results points")
    assert_equal(3, senior_men_overall_bar.results[1].scores.size, "Weaver Overall BAR results scores")

    assert_equal(racers(:molly), senior_men_overall_bar.results[2].racer, "Senior Men Overall BAR results racer")
    assert_equal("3", senior_men_overall_bar.results[2].place, "Senior Men Overall BAR results place")
    assert_equal(598, senior_men_overall_bar.results[2].points, "Senior Men Overall BAR results points")
    
    women_overall_bar = overall_bar.races.detect do |b|
      b.name == "Senior Women"
    end
    assert_equal(categories(:senior_women), women_overall_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(2, women_overall_bar.results.size, "Senior Women Overall BAR results")

    women_overall_bar.results.sort!
    assert_equal(racers(:alice), women_overall_bar.results[0].racer, "Senior Women Overall BAR results racer")
    assert_equal("1", women_overall_bar.results[0].place, "Senior Women Overall BAR results place")
    assert_equal(300, women_overall_bar.results[0].points, "Senior Women Overall BAR results points")

    assert_equal(racers(:molly), women_overall_bar.results[1].racer, "Senior Women Overall BAR results racer")
    assert_equal("2", women_overall_bar.results[1].place, "Senior Women Overall BAR results place")
    assert_equal(299, women_overall_bar.results[1].points, "Senior Women Overall BAR results points")
    assert_equal(1, women_overall_bar.results[1].scores.size, "Molly Women Overall BAR results scores")
  end
  
  def test_recalculate_tandem
    tandem = Category.find_or_create_by_name("Tandem")
    crit_discipline = disciplines(:criterium)
    crit_discipline.bar_categories << tandem
    crit_discipline.save!
    crit_discipline.reload
    assert(crit_discipline.bar_categories.include?(tandem), 'Criterium Discipline should include Tandem category')
    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    })
    swan_island_standings = swan_island.standings.create!(:event => swan_island)
    swan_island_tandem = swan_island_standings.races.create!(:category => tandem)
    first_racers = Racer.new(:first_name => 'Scott/Cheryl', :last_name => 'Willson/Willson', :member_from => Date.new(2004, 1, 1))
    gentle_lovers = teams(:gentle_lovers)
    swan_island_tandem.results.create!({
      :place => 12,
      :racer => first_racers,
      :team => gentle_lovers
    })
    # Existing racers
    second_racers = Racer.create!(:first_name => 'Tim/John', :last_name => 'Johnson/Verhul', :member_from => Date.new(2004, 1, 1))
    second_racers_team = Team.create!(:name => 'Kona/Northampton Cycling Club')
    swan_island_tandem.results.create!({
      :place => 2,
      :racer => second_racers,
      :team => second_racers_team
    })

    Bar.recalculate(2004)
    OverallBar.recalculate(2004)
    bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 OverallBar after recalculate")
    
    overall_bar = bar.standings.first
    
    overall_tandem_bar = overall_bar.races.detect do |race|
      race.name == 'Tandem'
    end
    
    assert_not_nil(overall_tandem_bar, 'Overall Tandem BAR')
    assert_equal(2, overall_tandem_bar.results.size, 'Overall Tandem BAR results')
  end

  def test_pick_best_juniors_for_overall
    expert_junior_men = categories(:expert_junior_men)
    junior_men = categories(:junior_men)
    sport_junior_men = categories(:sport_junior_men)

    # Masters too
    marin_knobular = SingleDayEvent.create!(:name => 'Marin Knobular', :date => Date.new(2001, 9, 7), :discipline => 'Mountain Bike')
    standings = marin_knobular.standings.create
    race = standings.races.create!(:category => expert_junior_men)
    kc = Racer.create!(:name => 'KC Mautner', :member_from => Date.new(2001, 1, 1))
    vanilla = teams(:vanilla)
    race.results.create!(:racer => kc, :place => 4, :team => vanilla)
    chris_woods = Racer.create!(:name => 'Chris Woods', :member_from => Date.new(2001, 1, 1))
    gentle_lovers = teams(:gentle_lovers)
    race.results.create!(:racer => chris_woods, :place => 12, :team => gentle_lovers)
    
    lemurian = SingleDayEvent.create!(:name => 'Lemurian', :date => Date.new(2001, 9, 14), :discipline => 'Mountain Bike')
    standings = marin_knobular.standings.create
    race = standings.races.create!(:category => sport_junior_men)
    race.results.create!(:racer => chris_woods, :place => 14, :team => gentle_lovers)
    
    original_results_count = Result.count
    Bar.recalculate(2001)
    OverallBar.recalculate(2001)
    bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(2001, 1, 1)])
    assert_not_nil(bar, "2001 OverallBar after recalculate")
    assert_equal(1, OverallBar.count, "Bar events after recalculate")
    assert_equal(1, bar.standings.count, "Bar standings after recalculate")
    assert_equal(original_results_count + 5, Result.count, "Total count of results in DB")

    overall_bar = bar.standings.first
    overall_junior_men_mtb_bar = overall_bar.races.detect do |race|
      race.category == junior_men
    end
    assert_equal(2, overall_junior_men_mtb_bar.results.size, 'Overall Junior Men BAR results')
    overall_junior_men_mtb_bar.results.sort! {|x, y| x.racer <=> y.racer}
    assert_equal(kc, overall_junior_men_mtb_bar.results.first.racer, 'Overall Junior Men BAR first result')
    assert_equal(chris_woods, overall_junior_men_mtb_bar.results.last.racer, 'Overall Junior Men BAR last result')
    assert_equal(300, overall_junior_men_mtb_bar.results.first.points, 'Overall Junior Men BAR first points')
    assert_equal(300, overall_junior_men_mtb_bar.results.last.points, 'Overall Junior Men BAR last points')
  end
  
  def test_previous_year
    weaver = racers(:weaver)
    previous_year = Date.today.year - 1
    weaver.member_from = Date.new(previous_year, 1, 1)
    current_year = Date.today.year - 1
    weaver.member_to = Date.new(current_year, 12, 31)
    weaver.save!
    
    # Create result for previous year
    previous_year_event = SingleDayEvent.create!(:date => Date.new(previous_year, 4, 19), :discipline => 'Road')
    previous_year_event.reload
    assert_equal('Road', previous_year_event.discipline, 'Event discipline')
    previous_year_result = previous_year_event.standings.create.races.create!(:category => categories(:sr_p_1_2)).results.create!(:place => '3', :racer => weaver)
    standings = previous_year_event.standings(true)
    assert_equal(1, standings.size, 'Standings size')
    assert_equal(previous_year, standings.first.date.year, 'Standings year')
    assert_equal('Road', standings.first.discipline, 'Standings discipline')
    assert_equal(1, standings.first.bar_points, 'BAR points')
    assert_equal(1, standings.first.races(true).size, 'Races size')
    assert_equal(categories(:sr_p_1_2), standings.first.races(true).first.category, 'Category')
    assert_not_nil(standings.first.races(true).first.category.parent, 'BAR Category')
    
    # Calculate previous years' BAR
    Bar.recalculate(previous_year)
    OverallBar.recalculate(previous_year)
    previous_year_bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    
    # Assert it has results
    previous_year_overall_bar = previous_year_bar.standings.first
    previous_year_sr_men_overall_bar = previous_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_overall_bar.results.empty?, 'Previous year OverallBar should have results')
    
    # Create result for this year
    current_year_event = SingleDayEvent.create!(:date => Date.new(current_year, 7, 20), :discipline => 'Road')
    current_year_event.reload
    assert_equal('Road', current_year_event.discipline, 'Event discipline')
    current_year_result = current_year_event.standings.create.races.create!(:category => categories(:sr_p_1_2)).results.create!(:place => '13', :racer => weaver)

    # Calculate this years' BAR
    Bar.recalculate(current_year)
    OverallBar.recalculate(current_year)

    # Assert both BARs have results
    previous_year_bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    previous_year_overall_bar = previous_year_bar.standings.first
    previous_year_sr_men_overall_bar = previous_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_overall_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(current_year, 1, 1)])
    current_year_overall_bar = current_year_bar.standings.first
    current_year_sr_men_overall_bar = current_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!current_year_sr_men_overall_bar.results.empty?, 'Current year BAR should have results')

    # Recalc both BARs
    OverallBar.recalculate(previous_year)
    OverallBar.recalculate(current_year)

    # Assert both BARs have results
    previous_year_bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    previous_year_overall_bar = previous_year_bar.standings.first
    previous_year_sr_men_overall_bar = previous_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_overall_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(current_year, 1, 1)])
    current_year_overall_bar = current_year_bar.standings.first
    current_year_sr_men_overall_bar = current_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!current_year_sr_men_overall_bar.results.empty?, 'Current year BAR should have results')
  end
  
  def test_drop_cat_5_discipline_results
    category_4_5_men = categories(:men_4_5)
    category_4_men = categories(:category_4_men)
    category_5_men = categories(:category_5_men)

    standings = SingleDayEvent.create!(:discipline => 'Road').standings.create!
    cat_4_race = standings.races.create!(:category => category_4_men)
    weaver = racers(:weaver)
    matson = racers(:matson)
    cat_4_race.results.create!(:place => '4', :racer => weaver)
    cat_4_race.results.create!(:place => '5', :racer => matson)

    cat_5_race = standings.races.create!(:category => category_5_men)
    cat_5_race.results.create!(:place => '6', :racer => matson)
    tonkin = racers(:tonkin)
    cat_5_race.results.create!(:place => '15', :racer => tonkin)
    
    standings = SingleDayEvent.create!(:discipline => 'Road').standings.create!
    cat_5_race = standings.races.create!(:category => category_5_men)
    cat_5_race.results.create!(:place => '15', :racer => tonkin)
    
    # Add several different discipline results to expose ordering bug
    standings = SingleDayEvent.create!(:discipline => "Criterium").standings.create!
    standings.races.create!(:category => category_4_men).results.create!(:place => 3, :racer => matson)
    standings.races.create!(:category => category_4_men).results.create!(:place => 6, :racer => tonkin)
    standings.races.create!(:category => category_4_men).results.create!(:place => 12, :racer => racers(:molly))
    standings.races.create!(:category => category_4_men).results.create!(:place => 15, :racer => weaver)
    
    standings = SingleDayEvent.create!(:discipline => "Mountain Bike").standings.create!
    standings.races.create!(:category => Category.find_or_create_by_name("Beginner Men")).results.create!(:place => 14, :racer => matson)
    standings.races.create!(:category => Category.find_or_create_by_name("Beginner Men")).results.create!(:place => 15, :racer => weaver)
    
    standings = SingleDayEvent.create!(:discipline => "Track").standings.create!
    standings.races.create!(:category => category_4_men).results.create!(:place => 6, :racer => tonkin)
    standings.races.create!(:category => category_4_men).results.create!(:place => 14, :racer => matson)
    standings.races.create!(:category => category_4_men).results.create!(:place => 15, :racer => weaver)

    standings.races.create!(:category => category_5_men).results.create!(:place => 1, :racer => weaver)
    
    standings = SingleDayEvent.create!(:discipline => "Time Trial").standings.create!
    standings.races.create!(:category => category_5_men).results.create!(:place => 1, :racer => weaver)
    standings.races.create!(:category => category_5_men).results.create!(:place => 15, :racer => matson)
    
    Bar.recalculate
    OverallBar.recalculate
    
    current_year = Date.today.year
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(current_year, 1, 1)])
    road_bar_standings = bar.standings.detect { |standings| standings.discipline == "Road" }
    cat_4_road_bar = road_bar_standings.races.detect { |race| race.category == category_4_men }
    assert_equal(2, cat_4_road_bar.results.size, "Cat 4 Overall BAR results")
    cat_5_road_bar = road_bar_standings.races.detect { |race| race.category == category_5_men }
    assert_equal(2, cat_5_road_bar.results.size, "Cat 5 Overall BAR results")
    
    overall_bar = OverallBar.find(:first, :conditions => ['date = ?', Date.new(current_year, 1, 1)])
    overall_bar_standings = overall_bar.standings.first
    cat_4_5_overall_bar = overall_bar_standings.races.detect { |race| race.category == category_4_5_men }
    assert_equal(4, cat_4_5_overall_bar.results.size, "Cat 4/5 Overall BAR results")
    cat_4_5_overall_bar.results.sort!

    matson_result = cat_4_5_overall_bar.results.detect { |result| result.racer == matson }
    assert_equal("1", matson_result.place, "Matson Cat 4/5 Overall BAR place")
    assert_equal(1248.0, matson_result.points, "Matson Cat 4/5 Overall BAR points")
    assert_equal(5, matson_result.scores.size, "Matson Cat 4/5 Overall BAR 1st place scores")

    weaver_result = cat_4_5_overall_bar.results.detect { |result| result.racer == weaver }
    assert_equal("2", weaver_result.place, "Weaver Cat 4/5 Overall BAR place")
    assert_equal(300, weaver_result.scores.detect { |s| s.source_result.race.standings.name == "Road" }.points, "Road points")
    assert_equal(300, weaver_result.scores.detect { |s| s.source_result.race.standings.name == "Time Trial" }.points, "Time Trial points")
    assert_equal(299, weaver_result.scores.detect { |s| s.source_result.race.standings.name == "Mountain Bike" }.points, "Mountain Bike points")
    assert_equal(298, weaver_result.scores.detect { |s| s.source_result.race.standings.name == "Track" }.points, "Track points")
    assert_equal(50, weaver_result.scores.detect { |s| s.source_result.race.standings.name == "Criterium" }.points, "Criterium points")
    assert_equal(300 + 300 + 299 + 298 + 50, weaver_result.points, "Weaver Cat 4/5 Overall BAR points")
    assert_equal(5, weaver_result.scores.size, "Weaver Cat 4/5 Overall BAR 1st place scores")

    tonkin_result = cat_4_5_overall_bar.results.detect { |result| result.racer == tonkin }
    assert_equal("3", tonkin_result.place, "Tonkin Cat 4/5 Overall BAR place")
    assert_equal(898.0, tonkin_result.points, "Tonkin Cat 4/5 Overall BAR points")
    assert_equal(3, tonkin_result.scores.size, "Tonkin Cat 4/5 Overall BAR 1st place scores")
    tonkin_score = tonkin_result.scores.first
    assert_equal(category_5_men, tonkin_score.source_result.race.category, "Tonkin source result category")
  end
  
  def test_remove_duplicate_discipline_results
    # No scores
    bar = OverallBar.new
    scores = []
    bar.remove_duplicate_discipline_results(scores)
    assert_equal([], scores, "Empty scores")
    
    # One score
    scores = []
    standings = SingleDayEvent.create!(:discipline => 'Road').standings.create!
    category_4_men = Category.find_or_create_by_name("Category 4 Men")
    race = standings.races.create!(:category => category_4_men)
    racer = racers(:molly)
    source_result = race.results.create!(:place => "1", :racer => racer)
    competition_result = Result.create!(:racer => racer, :race => race)
    score = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << score
    bar.remove_duplicate_discipline_results(scores)
    assert_equal([score], scores, "Should keep single score")
    
    # Multiple scores
    scores = []
    standings = SingleDayEvent.create!(:discipline => 'Road').standings.create!
    race = standings.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :racer => racer)
    competition_result = Result.create!(:racer => racer, :race => race)
    road_score = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << road_score
    
    standings = SingleDayEvent.create!(:discipline => 'Cyclocross').standings.create!
    race = standings.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :racer => racer)
    competition_result = Result.create!(:racer => racer, :race => race)
    cx_score = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << cx_score
    
    standings = SingleDayEvent.create!(:discipline => 'Track').standings.create!
    race = standings.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :racer => racer)
    competition_result = Result.create!(:racer => racer, :race => race)
    track_score = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << track_score

    scores.sort! {|x, y| y.points.to_i <=> x.points.to_i}
    bar.remove_duplicate_discipline_results(scores)
    assert_equal([road_score, cx_score, track_score], scores, 
      "Should keep three scores from different disciplines")
      
    # Duplicate disciplines
    scores = []
    standings = SingleDayEvent.create!(:discipline => 'Road').standings.create!
    race = standings.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :racer => racer)
    competition_result = Result.create!(:racer => racer, :race => race)
    road_score_10 = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 10
    )    
    scores << road_score_10
    
    standings = SingleDayEvent.create!(:discipline => 'Cyclocross').standings.create!
    race = standings.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :racer => racer)
    competition_result = Result.create!(:racer => racer, :race => race)
    cx_score_1 = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << cx_score_1
    
    standings = SingleDayEvent.create!(:discipline => 'Cyclocross').standings.create!
    race = standings.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "2", :racer => racer)
    competition_result = Result.create!(:racer => racer, :race => race)
    cx_score_2 = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 2
    )    
    scores << cx_score_2
    
    standings = SingleDayEvent.create!(:discipline => 'Track').standings.create!
    race = standings.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :racer => racer)
    competition_result = Result.create!(:racer => racer, :race => race)
    track_score = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << track_score

    standings = SingleDayEvent.create!(:discipline => 'Road').standings.create!
    race = standings.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :racer => racer)
    competition_result = Result.create!(:racer => racer, :race => race)
    road_score_1 = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << road_score_1
    
    scores.sort! {|x, y| y.points.to_i <=> x.points.to_i}
    bar.remove_duplicate_discipline_results(scores)
    assert_equal([road_score_10, cx_score_2, track_score], scores, 
      "Should keep three scores from different disciplines")      
  end
end