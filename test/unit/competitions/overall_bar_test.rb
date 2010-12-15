# There is duplication between BAR tests, but refactring the tests should wait until the Competition refactoring is complete

require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class OverallBarTest < ActiveSupport::TestCase
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
    barton_a = barton.races.create!(:category => men_a, :field_size => 5)
    barton_a.results.create!({
      :place => 3,
      :person => people(:tonkin)
    })
    barton_a.results.create!({
      :place => 15,
      :person => people(:weaver)
    })
    
    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    })
    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    swan_island_senior_men = swan_island.races.create!(:category => senior_men, :field_size => 4)
    swan_island_senior_men.results.create!({
      :place => 12,
      :person => people(:tonkin)
    })
    swan_island_senior_men.results.create!({
      :place => 2,
      :person => people(:molly)
    })
    senior_women = Category.find_by_name("Senior Women")
    senior_women_swan_island = swan_island.races.create!(:category => senior_women, :field_size => 3)
    senior_women_swan_island.results.create!({
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
    thursday_track_senior_men = thursday_track.races.create!(:category => senior_men, :field_size => 6)
    r = thursday_track_senior_men.results.create!(
      :place => 5,
      :person => people(:weaver)
    )
    thursday_track_senior_men.results.create!(
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
    team_track_senior_men = team_track.races.create!(:category => senior_men, :field_size => 6)
    team_track_senior_men.results.create!({
      :place => 1,
      :person => people(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create!({
      :place => 1,
      :person => people(:tonkin),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create!({
      :place => 1,
      :person => people(:molly)
    })
    team_track_senior_men.results.create!({
      :place => 5,
      :person => people(:alice)
    })
    team_track_senior_men.results.create!({
      :place => 5,
      :person => people(:matson)
    })
    # Weaver and Erik's second ride should not count
    team_track_senior_men.results.create!({
      :place => 15,
      :person => people(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create!({
      :place => 15,
      :person => people(:tonkin),
      :team => teams(:kona)
    })
    
    larch_mt_hillclimb = SingleDayEvent.create!({
      :name => "Larch Mountain Hillclimb",
      :discipline => "Time Trial",
      :date => Date.new(2004, 2, 1)
    })
    larch_mt_hillclimb_senior_men = larch_mt_hillclimb.races.create!(:category => senior_men, :field_size => 6)
    larch_mt_hillclimb_senior_men.results.create!({
      :place => 13,
      :person => people(:tonkin),
      :team => teams(:kona)
    })
      
    assert_equal(0, Bar.count, "Bar before calculate!")
    original_results_count = Result.count
    Bar.calculate!(2004)
    
    # Discipline BAR results past 300 don't count -- add fake result
    bar = Bar.find_by_year_and_discipline(2004, "Road")
    assert_not_nil bar.parent, "Should have parent"
    sr_men_road_bar = bar.races.detect {|r| r.category == categories(:senior_men)}
    sr_men_road_bar.results.create!(:place => 305, :person => people(:alice))
    
    OverallBar.calculate!(2004)
    bar = OverallBar.first(:conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Bar after calculate!")
    assert_equal(1, OverallBar.count, "Overall BARs after calculate! #{OverallBar.all.map(&:date).join(", ")}")
    assert_equal(original_results_count + 23, Result.count, "Total count of results in DB")
    # Should delete old BAR
    OverallBar.calculate!(2004)
    assert_equal(1, OverallBar.count, "Bar events after calculate!")
    overall_bar = OverallBar.first(:conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(overall_bar, "2004 Bar after calculate!")
    assert_equal(Date.new(2004, 1, 1), overall_bar.date, "2004 Bar date")
    assert_equal("2004 Overall BAR", overall_bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, overall_bar.updated_at, "BAR last updated")
    assert_equal(original_results_count + 23, Result.count, "Total count of results in DB")

    assert_equal("2004 Overall BAR", overall_bar.name, "2004 Overall Bar name")
    assert_equal(13, overall_bar.races.size, "2004 Overall Bar races")
    assert_equal_dates(Date.today, overall_bar.updated_at, "BAR last updated")
    assert_equal 6, overall_bar.children.size, "Overall BAR children"
    
    senior_men_overall_bar = overall_bar.races.detect do |b|
      b.name == "Senior Men"
    end
    
    assert_equal(categories(:senior_men), senior_men_overall_bar.category, "Senior Men BAR race BAR cat")
    assert_equal(5, senior_men_overall_bar.results.size, "Senior Men Overall BAR results")
    assert_equal_dates(Date.today, senior_men_overall_bar.updated_at, "BAR last updated")
    senior_men_overall_bar.results.sort!
    
    assert_equal(people(:tonkin), senior_men_overall_bar.results[0].person, "Senior Men Overall BAR results person")
    assert_equal("1", senior_men_overall_bar.results[0].place, "Senior Men Overall BAR results place")
    assert_equal(1498, senior_men_overall_bar.results[0].points, "Tonkin Senior Men Overall BAR results points")
    assert_equal(5, senior_men_overall_bar.results[0].scores.size, "Tonkin Overall BAR results scores")
    scores = senior_men_overall_bar.results[0].scores.sort {|x, y| y.points <=> x.points}
    assert_equal(300, scores[0].points, "Tonkin overall BAR points for discipline 0")
    assert_equal(300, scores[1].points, "Tonkin overall BAR points for discipline 1")
    assert_equal(300, scores[2].points, "Tonkin overall BAR points for discipline 2")
    assert_equal(299, scores[3].points, "Tonkin overall BAR points for discipline 3")
    assert_equal(299, scores[4].points, "Tonkin overall BAR points for discipline 4")

    assert_equal(people(:weaver), senior_men_overall_bar.results[1].person, "Senior Men Overall BAR results person")
    assert_equal("2", senior_men_overall_bar.results[1].place, "Senior Men Overall BAR results place")
    assert_equal(898, senior_men_overall_bar.results[1].points, "Senior Men Overall BAR results points")
    assert_equal(3, senior_men_overall_bar.results[1].scores.size, "Weaver Overall BAR results scores")

    assert_equal(people(:molly), senior_men_overall_bar.results[2].person, "Senior Men Overall BAR results person")
    assert_equal("3", senior_men_overall_bar.results[2].place, "Senior Men Overall BAR results place")
    assert_equal(596, senior_men_overall_bar.results[2].points, "Senior Men Overall BAR results points")
    
    women_overall_bar = overall_bar.races.detect do |b|
      b.name == "Senior Women"
    end
    assert_equal(categories(:senior_women), women_overall_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(2, women_overall_bar.results.size, "Senior Women Overall BAR results")

    women_overall_bar.results.sort!
    assert_equal(people(:alice), women_overall_bar.results[0].person, "Senior Women Overall BAR results person")
    assert_equal("1", women_overall_bar.results[0].place, "Senior Women Overall BAR results place")
    assert_equal(300, women_overall_bar.results[0].points, "Senior Women Overall BAR results points")

    assert_equal(people(:molly), women_overall_bar.results[1].person, "Senior Women Overall BAR results person")
    assert_equal("2", women_overall_bar.results[1].place, "Senior Women Overall BAR results place")
    assert_equal(299, women_overall_bar.results[1].points, "Senior Women Overall BAR results points")
    assert_equal(1, women_overall_bar.results[1].scores.size, "Molly Women Overall BAR results scores")
  end
  
  def test_calculate_tandem
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
    swan_island_tandem = swan_island.races.create!(:category => tandem)
    first_people = Person.new(:first_name => 'Scott/Cheryl', :last_name => 'Willson/Willson', :member_from => Date.new(2004, 1, 1))
    gentle_lovers = teams(:gentle_lovers)
    swan_island_tandem.results.create!({
      :place => 12,
      :person => first_people,
      :team => gentle_lovers
    })
    # Existing people
    second_people = Person.create!(:first_name => 'Tim/John', :last_name => 'Johnson/Verhul', :member_from => Date.new(2004, 1, 1))
    second_people_team = Team.create!(:name => 'Kona/Northampton Cycling Club')
    swan_island_tandem.results.create!({
      :place => 2,
      :person => second_people,
      :team => second_people_team
    })

    Bar.calculate!(2004)
    OverallBar.calculate!(2004)
    overall_bar = OverallBar.first(:conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(overall_bar, "2004 OverallBar after calculate!")
    
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
    race = marin_knobular.races.create!(:category => expert_junior_men)
    kc = Person.create!(:name => 'KC Mautner', :member_from => Date.new(2001, 1, 1))
    vanilla = teams(:vanilla)
    race.results.create!(:person => kc, :place => 4, :team => vanilla)
    chris_woods = Person.create!(:name => 'Chris Woods', :member_from => Date.new(2001, 1, 1))
    gentle_lovers = teams(:gentle_lovers)
    race.results.create!(:person => chris_woods, :place => 12, :team => gentle_lovers)
    
    lemurian = SingleDayEvent.create!(:name => 'Lemurian', :date => Date.new(2001, 9, 14), :discipline => 'Mountain Bike')
    race = lemurian.races.create!(:category => sport_junior_men)
    race.results.create!(:person => chris_woods, :place => 14, :team => gentle_lovers)
    
    original_results_count = Result.count
    Bar.calculate!(2001)
    OverallBar.calculate!(2001)
    assert_equal(1, OverallBar.count, "Bar events after calculate!")
    assert_equal(original_results_count + 4, Result.count, "Total count of results in DB")

    overall_bar = OverallBar.first(:conditions => ['date = ?', Date.new(2001, 1, 1)])
    assert_not_nil(overall_bar, "2001 OverallBar after calculate!")
    overall_junior_men_mtb_bar = overall_bar.races.detect do |race|
      race.category == junior_men
    end
    assert_equal(2, overall_junior_men_mtb_bar.results.size, 'Overall Junior Men BAR results')
    overall_junior_men_mtb_bar.results.sort! {|x, y| x.person <=> y.person}
    assert_equal(kc, overall_junior_men_mtb_bar.results.first.person, 'Overall Junior Men BAR first result')
    assert_equal(chris_woods, overall_junior_men_mtb_bar.results.last.person, 'Overall Junior Men BAR last result')
    assert_equal(300, overall_junior_men_mtb_bar.results.first.points, 'Overall Junior Men BAR first points')
    assert_equal(299, overall_junior_men_mtb_bar.results.last.points, 'Overall Junior Men BAR last points')
  end
  
  def test_previous_year
    weaver = people(:weaver)
    previous_year = Date.today.year - 1
    weaver.member_from = Date.new(previous_year, 1, 1)
    current_year = Date.today.year - 1
    weaver.member_to = Date.new(current_year, 12, 31)
    weaver.save!
    
    # Create result for previous year
    previous_year_event = SingleDayEvent.create!(:date => Date.new(previous_year, 4, 19), :discipline => 'Road')
    previous_year_event.reload
    assert_equal('Road', previous_year_event.discipline, 'Event discipline')
    previous_year_result = previous_year_event.races.create!(:category => categories(:sr_p_1_2)).results.create!(:place => '3', :person => weaver)
    assert_equal(previous_year, previous_year_event.date.year, 'Event year')
    assert_equal('Road', previous_year_event.discipline, 'Event discipline')
    assert_equal(1, previous_year_event.bar_points, 'BAR points')
    assert_equal(1, previous_year_event.races(true).size, 'Races size')
    assert_equal(categories(:sr_p_1_2), previous_year_event.races(true).first.category, 'Category')
    assert_not_nil(previous_year_event.races(true).first.category.parent, 'BAR Category')
    
    # Calculate previous years' BAR
    Bar.calculate!(previous_year)
    OverallBar.calculate!(previous_year)
    previous_year_overall_bar = OverallBar.first(:conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    
    # Assert it has results
    previous_year_sr_men_overall_bar = previous_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_overall_bar.results.empty?, 'Previous year OverallBar should have results')
    
    # Create result for this year
    current_year_event = SingleDayEvent.create!(:date => Date.new(current_year, 7, 20), :discipline => 'Road')
    current_year_event.reload
    assert_equal('Road', current_year_event.discipline, 'Event discipline')
    current_year_result = current_year_event.races.create!(:category => categories(:sr_p_1_2)).results.create!(:place => '13', :person => weaver)

    # Calculate this years' BAR
    Bar.calculate!(current_year)
    OverallBar.calculate!(current_year)

    # Assert both BARs have results
    previous_year_overall_bar = OverallBar.first(:conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    previous_year_sr_men_overall_bar = previous_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_overall_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_overall_bar = OverallBar.first(:conditions => ['date = ?', Date.new(current_year, 1, 1)])
    current_year_sr_men_overall_bar = current_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!current_year_sr_men_overall_bar.results.empty?, 'Current year BAR should have results')

    # Recalc both BARs
    OverallBar.calculate!(previous_year)
    OverallBar.calculate!(current_year)

    # Assert both BARs have results
    previous_year_overall_bar = OverallBar.first(:conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    previous_year_sr_men_overall_bar = previous_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!previous_year_sr_men_overall_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_overall_bar = OverallBar.first(:conditions => ['date = ?', Date.new(current_year, 1, 1)])
    current_year_sr_men_overall_bar = current_year_overall_bar.races.detect {|race| race.category == categories(:senior_men)}
    assert(!current_year_sr_men_overall_bar.results.empty?, 'Current year BAR should have results')
  end
  
  def test_drop_cat_5_discipline_results
    category_4_5_men = categories(:men_4_5)
    category_4_men = categories(:category_4_men)
    category_5_men = categories(:category_5_men)

    mtb = Discipline[:mtb]
    men_3 = Category.find_or_create_by_name("Category 3 Men")
    category_3_men = Category.find_or_create_by_name("Category 3 Men")
    mtb.bar_categories << men_3

    event = SingleDayEvent.create!(:discipline => 'Road')
    cat_4_race = event.races.create!(:category => category_4_men)
    weaver = people(:weaver)
    matson = people(:matson)
    cat_4_race.results.create!(:place => '4', :person => weaver)
    cat_4_race.results.create!(:place => '5', :person => matson)

    cat_5_race = event.races.create!(:category => category_5_men)
    cat_5_race.results.create!(:place => '6', :person => matson)
    tonkin = people(:tonkin)
    cat_5_race.results.create!(:place => '15', :person => tonkin)
    
    event = SingleDayEvent.create!(:discipline => 'Road')
    cat_5_race = event.races.create!(:category => category_5_men)
    cat_5_race.results.create!(:place => '15', :person => tonkin)
    
    # Add several different discipline results to expose ordering bug
    event = SingleDayEvent.create!(:discipline => "Criterium")
    event.races.create!(:category => category_4_men).results.create!(:place => 3, :person => matson)
    event.races.create!(:category => category_4_men).results.create!(:place => 6, :person => tonkin)
    event.races.create!(:category => category_4_men).results.create!(:place => 12, :person => people(:molly))
    event.races.create!(:category => category_4_men).results.create!(:place => 15, :person => weaver)
    
    event = SingleDayEvent.create!(:discipline => "Mountain Bike")
    event.races.create!(:category => Category.find_or_create_by_name("Category 3 Men")).results.create!(:place => 14, :person => matson)
    event.races.create!(:category => Category.find_or_create_by_name("Category 3 Men")).results.create!(:place => 15, :person => weaver)
    
    event = SingleDayEvent.create!(:discipline => "Track")
    event.races.create!(:category => category_4_men).results.create!(:place => 6, :person => tonkin)
    event.races.create!(:category => category_4_men).results.create!(:place => 14, :person => matson)
    event.races.create!(:category => category_4_men).results.create!(:place => 15, :person => weaver)

    event.races.create!(:category => category_5_men).results.create!(:place => 1, :person => weaver)
    
    sevent = SingleDayEvent.create!(:discipline => "Time Trial")
    sevent.races.create!(:category => category_5_men).results.create!(:place => 1, :person => weaver)
    sevent.races.create!(:category => category_5_men).results.create!(:place => 15, :person => matson)
    
    Bar.calculate!
    OverallBar.calculate!
    
    current_year = Date.today.year
    road_bar = Bar.find_by_year_and_discipline(current_year, "Road")
    cat_4_road_bar = road_bar.races.detect { |race| race.category == category_4_men }
    assert_equal(2, cat_4_road_bar.results.size, "Cat 4 Overall BAR results")
    cat_5_road_bar = road_bar.races.detect { |race| race.category == category_5_men }
    assert_equal(2, cat_5_road_bar.results.size, "Cat 5 Overall BAR results")
    
    overall_bar = OverallBar.find_by_date(Date.new(current_year, 1, 1))
    cat_4_5_overall_bar = overall_bar.races.detect { |race| race.category == category_4_5_men }
    assert_equal(4, cat_4_5_overall_bar.results.size, "Cat 4/5 Overall BAR results")
    cat_4_5_overall_bar.results.sort!

    matson_result = cat_4_5_overall_bar.results.detect { |result| result.person == matson }
    assert_equal("1", matson_result.place, "Matson Cat 4/5 Overall BAR place")
    assert_equal(1497.0, matson_result.points, "Matson Cat 4/5 Overall BAR points")
    assert_equal(5, matson_result.scores.size, "Matson Cat 4/5 Overall BAR 1st place scores")

    weaver_result = cat_4_5_overall_bar.results.detect { |result| result.person == weaver }
    assert_equal("2", weaver_result.place, "Weaver Cat 4/5 Overall BAR place")
    assert_equal(300, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Road" }.points, "Road points")
    assert_equal(300, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Time Trial" }.points, "Time Trial points")
    assert_equal(299, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Mountain Bike" }.points, "Mountain Bike points")
    assert_equal(298, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Track" }.points, "Track points")
    assert_equal(297, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Criterium" }.points, "Criterium points")
    assert_equal(300 + 300 + 299 + 298 + 297, weaver_result.points, "Weaver Cat 4/5 Overall BAR points")
    assert_equal(5, weaver_result.scores.size, "Weaver Cat 4/5 Overall BAR 1st place scores")

    tonkin_result = cat_4_5_overall_bar.results.detect { |result| result.person == tonkin }
    assert_equal("3", tonkin_result.place, "Tonkin Cat 4/5 Overall BAR place")
    assert_equal(898.0, tonkin_result.points, "Tonkin Cat 4/5 Overall BAR points")
    assert_equal(3, tonkin_result.scores.size, "Tonkin Cat 4/5 Overall BAR 1st place scores")
    assert_equal(299, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Road" }.points, "Road points")
    assert_equal(category_5_men, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Road" }.source_result.race.category, "Road category")
    assert_equal(300, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Track" }.points, "Track points")
    assert_equal(category_4_men, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Track" }.source_result.race.category, "Road category")
    assert_equal(299, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Criterium" }.points, "Criterium points")
    assert_equal(category_4_men, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Criterium" }.source_result.race.category, "Road category")
  end
  
  def test_remove_duplicate_discipline_results
    # No scores
    bar = OverallBar.new
    scores = []
    bar.remove_duplicate_discipline_results(scores)
    assert_equal([], scores, "Empty scores")
    
    # One score
    scores = []
    event = SingleDayEvent.create!(:discipline => 'Road')
    category_4_men = Category.find_or_create_by_name("Category 4 Men")
    race = event.races.create!(:category => category_4_men)
    person = people(:molly)
    source_result = race.results.create!(:place => "1", :person => person)
    competition_result = Result.create!(:person => person, :race => race)
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
    event = SingleDayEvent.create!(:discipline => 'Road')
    race = event.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :person => person)
    competition_result = Result.create!(:person => person, :race => race)
    road_score = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << road_score
    
    event = SingleDayEvent.create!(:discipline => 'Cyclocross')
    race = event.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :person => person)
    competition_result = Result.create!(:person => person, :race => race)
    cx_score = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << cx_score
    
    event = SingleDayEvent.create!(:discipline => 'Track')
    race = event.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :person => person)
    competition_result = Result.create!(:person => person, :race => race)
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
    event = SingleDayEvent.create!(:discipline => 'Road')
    race = event.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :person => person)
    competition_result = Result.create!(:person => person, :race => race)
    road_score_10 = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 10
    )    
    scores << road_score_10
    
    event = SingleDayEvent.create!(:discipline => 'Cyclocross')
    race = event.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :person => person)
    competition_result = Result.create!(:person => person, :race => race)
    cx_score_1 = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << cx_score_1
    
    event = SingleDayEvent.create!(:discipline => 'Cyclocross')
    race = event.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "2", :person => person)
    competition_result = Result.create!(:person => person, :race => race)
    cx_score_2 = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 2
    )    
    scores << cx_score_2
    
    event = SingleDayEvent.create!(:discipline => 'Track')
    race = event.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :person => person)
    competition_result = Result.create!(:person => person, :race => race)
    track_score = competition_result.scores.create_if_best_result_for_race(
      :source_result => source_result, 
      :competition_result => competition_result, 
      :points => 1
    )    
    scores << track_score

    event = SingleDayEvent.create!(:discipline => 'Road')
    race = event.races.create!(:category => category_4_men)
    source_result = race.results.create!(:place => "1", :person => person)
    competition_result = Result.create!(:person => person, :race => race)
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
