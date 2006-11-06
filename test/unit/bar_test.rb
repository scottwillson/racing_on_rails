require File.dirname(__FILE__) + '/../test_helper'
require 'bar'

class BarTest < Test::Unit::TestCase
  
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
    men_a = Category.find_association("Men A")
    barton_a = barton_standings.races.create(:category => men_a, :field_size => 5)
    barton_a.results.create({
      :place => 3,
      :racer => racers(:tonkin)
    })
    barton_a.results.create({
      :place => 15,
      :racer => racers(:weaver)
    })
    
    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    })
    swan_island_standings = swan_island.standings.create
    senior_men = Category.find_association("Senior Men Pro 1/2")
    swan_island_senior_men = swan_island_standings.races.create(:category => senior_men, :field_size => 5)
    swan_island_senior_men.results.create({
      :place => 12,
      :racer => racers(:tonkin)
    })
    swan_island_senior_men.results.create({
      :place => 2,
      :racer => racers(:mollie)
    })
    senior_women = Category.find_association("Senior Women")
    senior_women_swan_island = swan_island_standings.races.create(:category => senior_women, :field_size => 6)
    senior_women_swan_island.results.create({
      :place => 1,
      :racer => racers(:mollie)
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
      :racer => racers(:mollie)
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
    assert_equal(27, Result.count, "Total count of results in DB before BAR recalculate")
    Bar.recalculate(2004)
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Bar after recalculate")
    assert_equal(1, Bar.count, "Bar events after recalculate")
    assert_equal(8, bar.standings.count, "Bar standings after recalculate")
    assert_equal(52, Result.count, "Total count of results in DB")
    # Should delete old BAR
    Bar.recalculate(2004)
    assert_equal(1, Bar.count, "Bar events after recalculate")
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Bar after recalculate")
    assert_equal(8, bar.standings.count, "Bar standings after recalculate")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 Bar date")
    assert_equal("2004 BAR", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "BAR last updated")
    assert_equal(52, Result.count, "Total count of results in DB")

    overall_bar = bar.standings.detect do |standings|
      standings.name == 'Overall'
    end

    assert_equal("Overall", overall_bar.name, "2004 Overall Bar name")
    assert_equal(4, overall_bar.races.size, "2004 Overall Bar races")
    assert_equal_dates(Date.today, overall_bar.updated_at, "BAR last updated")
    
    senior_men_overall_bar = overall_bar.races.detect do |b|
      b.name == "Senior Men"
    end
    
    assert_equal(categories(:senior_men_bar), senior_men_overall_bar.category, "Senior Men BAR race BAR cat")
    assert_equal(5, senior_men_overall_bar.results.size, "Senior Men Overall BAR results")
    assert_equal_dates(Date.today, senior_men_overall_bar.updated_at, "BAR last updated")
    
    racers(:tonkin).results(true) do |result|
      puts(result)
    end

    assert_equal(racers(:tonkin), senior_men_overall_bar.results[0].racer, "Senior Men Overall BAR results racer")
    assert_equal("1", senior_men_overall_bar.results[0].place, "Senior Men Overall BAR results place")
    assert_equal(1249, senior_men_overall_bar.results[0].points, "Senior Men Overall BAR results points")
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

    assert_equal(racers(:mollie), senior_men_overall_bar.results[2].racer, "Senior Men Overall BAR results racer")
    assert_equal("3", senior_men_overall_bar.results[2].place, "Senior Men Overall BAR results place")
    assert_equal(598, senior_men_overall_bar.results[2].points, "Senior Men Overall BAR results points")
    
    women_overall_bar = overall_bar.races.detect do |b|
      b.name == "Senior Women"
    end
    assert_equal(categories(:senior_women_bar), women_overall_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(2, women_overall_bar.results.size, "Senior Women Overall BAR results")

    assert_equal(racers(:alice), women_overall_bar.results[0].racer, "Senior Women Overall BAR results racer")
    assert_equal("1", women_overall_bar.results[0].place, "Senior Women Overall BAR results place")
    assert_equal(300, women_overall_bar.results[0].points, "Senior Women Overall BAR results points")

    assert_equal(racers(:mollie), women_overall_bar.results[1].racer, "Senior Women Overall BAR results racer")
    assert_equal("2", women_overall_bar.results[1].place, "Senior Women Overall BAR results place")
    assert_equal(299, women_overall_bar.results[1].points, "Senior Women Overall BAR results points")
    assert_equal(1, women_overall_bar.results[1].scores.size, "Mollie Women Overall BAR results scores")
    
    road_bar = bar.standings.detect do |standings|
      standings.name == 'Road'
    end
    assert_equal("Road", road_bar.name, "2004 Road Bar name")
    assert_equal(3, road_bar.races.size, "2004 Road Bar scores")
    assert_equal_dates(Date.today, road_bar.updated_at, "BAR last updated")
    
    senior_men_road_bar = road_bar.races.detect do |b|
      b.name == "Senior Men"
    end
    assert_equal(categories(:senior_men_bar), senior_men_road_bar.category, "Senior Men BAR race BAR cat")
    assert_equal(3, senior_men_road_bar.results.size, "Senior Men Road BAR results")
    assert_equal_dates(Date.today, senior_men_road_bar.updated_at, "BAR last updated")

    senior_men_road_bar.results.sort!
    assert_equal(racers(:tonkin), senior_men_road_bar.results[0].racer, "Senior Men Road BAR results racer")
    assert_equal("1", senior_men_road_bar.results[0].place, "Senior Men Road BAR results place")
    assert_equal(30, senior_men_road_bar.results[0].points, "Senior Men Road BAR results points")

    assert_equal(racers(:weaver), senior_men_road_bar.results[1].racer, "Senior Men Road BAR results racer")
    assert_equal("2", senior_men_road_bar.results[1].place, "Senior Men Road BAR results place")
    assert_equal(25, senior_men_road_bar.results[1].points, "Senior Men Road BAR results points")
    assert_equal(1, senior_men_road_bar.results[1].scores.size, "Weaver Road BAR results scores")

    assert_equal(racers(:matson), senior_men_road_bar.results[2].racer, "Senior Men Road BAR results racer")
    assert_equal("3", senior_men_road_bar.results[2].place, "Senior Men Road BAR results place")
    assert_equal(22, senior_men_road_bar.results[2].points, "Senior Men Road BAR results points")
    
    women_road_bar = road_bar.races.detect do |b|
      b.name == "Senior Women"
    end
    assert_equal(categories(:senior_women_bar), women_road_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(2, women_road_bar.results.size, "Senior Women Road BAR results")

    women_road_bar.results.sort!
    assert_equal(racers(:alice), women_road_bar.results[0].racer, "Senior Women Road BAR results racer")
    assert_equal("1", women_road_bar.results[0].place, "Senior Women Road BAR results place")
    assert_equal(25, women_road_bar.results[0].points, "Senior Women Road BAR results points")

    assert_equal(racers(:mollie), women_road_bar.results[1].racer, "Senior Women Road BAR results racer")
    assert_equal("2", women_road_bar.results[1].place, "Senior Women Road BAR results place")
    assert_equal(1, women_road_bar.results[1].points, "Senior Women Road BAR results points")
    assert_equal(1, women_road_bar.results[1].scores.size, "Mollie Women Road BAR results scores")
    
    track_bar = bar.standings.detect do |standings|
      standings.name == 'Track'
    end
    assert_not_nil(track_bar, 'Track BAR')
    sr_men_track = track_bar.races.detect {|r| r.bar_category.name == 'Senior Men'}
    assert_not_nil(sr_men_track, 'Senior Men Track BAR')
    tonkin_track_bar_result = sr_men_track.results.detect {|result| result.racer == racers(:tonkin)}
    assert_not_nil(tonkin_track_bar_result, 'Tonkin Track BAR result')
    assert_in_delta(22, tonkin_track_bar_result.points, 0.00001, 'Tonkin Track BAR points')
    
    team_standings = bar.standings.detect {|s| s.name == 'Team'}
    assert_equal(1, team_standings.races.size, 'Should have only one team BAR standings race')
    team_race = team_standings.races.first
    
    assert_equal(3, team_race.results.size, "Team BAR results")
    assert_equal_dates(Date.today, team_race.updated_at, "BAR last updated")

    team_race.results.sort!
    assert_equal(teams(:kona), team_race.results[0].team, "Team BAR results team")
    assert_equal("1", team_race.results[0].place, "Team BAR results place")
    assert_in_delta(117, team_race.results[0].points, 0.0001, "Team BAR results points")

    assert_equal(teams(:gentle_lovers), team_race.results[1].team, "Team BAR results team")
    assert_equal("2", team_race.results[1].place, "Team BAR results place")
    assert_equal(25, team_race.results[1].points, "Team BAR results points")

    assert_equal(teams(:vanilla), team_race.results[2].team, "Team BAR results team")
    assert_equal("3", team_race.results[2].place, "Team BAR results place")
    assert_equal(1, team_race.results[2].points, "Team BAR results points")

    # check placings for ties
    # remove one-day licensees
  end
  
  def test_recalculate_tandem
    tandem_bar = Category.create(:name => "Tandem", :scheme => 'BAR')
    tandem_bar.overall = tandem_bar
    tandem_bar.bar_category = tandem_bar
    tandem_bar.save!
    tandem_bar.reload
    assert_equal(tandem_bar, tandem_bar.overall, 'Tandem BAR overall category')
    assert_equal(tandem_bar, tandem_bar.bar_category, 'Tandem BAR\'s BAR category')
    tandem = Category.create(:name => "Tandem", :scheme => 'OBRA')
    tandem.bar_category = tandem_bar
    tandem.save!
    tandem.reload
    assert_equal(tandem_bar, tandem.bar_category, 'Tandem BAR category')
    crit_discipline = disciplines(:criterium)
    crit_discipline.bar_categories << tandem_bar
    crit_discipline.save!
    overall_discipline = disciplines(:overall)
    overall_discipline.bar_categories << tandem_bar
    overall_discipline.save!
    overall_discipline.reload
    assert(overall_discipline.bar_categories.include?(tandem_bar), 'Overall Discipline should include Tandem category')
    crit_discipline.reload
    assert(crit_discipline.bar_categories.include?(tandem_bar), 'Criterium Discipline should include Tandem category')
    swan_island = SingleDayEvent.create({
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    })
    swan_island_standings = swan_island.standings.create(:event => swan_island)
    swan_island_tandem = swan_island_standings.races.create(:category => tandem)
    first_racers = Racer.new(:first_name => 'Scott/Cheryl', :last_name => 'Willson/Willson')
    gentle_lovers = teams(:gentle_lovers)
    swan_island_tandem.results.create({
      :place => 12,
      :racer => first_racers,
      :team => gentle_lovers
    })
    second_racers = Racer.new(:first_name => 'Tim/John', :last_name => 'Johnson/Verhul')
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

    overall_bar = bar.standings.detect do |standings|
      standings.name == 'Overall'
    end
    
    overall_tandem_bar = overall_bar.races.detect do |race|
      race.name == 'Tandem'
    end
    
    assert_not_nil(overall_tandem_bar, 'Overall Tandem BAR')
    assert_equal(2, overall_tandem_bar.results.size, 'Overall Tandem BAR results')

    team_bar = bar.standings.detect do |standings|
      standings.name == 'Team'
    end

    team_bar_race = team_bar.races.first
    gentle_lovers_team_result = team_bar_race.results.detect do |result|
      result.team == gentle_lovers
    end
    swan_island_tandem_bar_result = gentle_lovers_team_result.scores.detect do |score|
      score.source_result.race == swan_island_tandem
    end
    assert_not_nil(swan_island_tandem_bar_result, 'Tandem results should count in Team BAR')
    assert_equal(4, swan_island_tandem_bar_result.points, 'Gentle Lovers Tandem BAR points')

    kona_team_result = team_bar_race.results.detect do |result|
      result.team == teams(:kona)
    end
    swan_island_tandem_bar_result = kona_team_result.scores.detect do |score|
      score.source_result.race == swan_island_tandem
    end
    assert_not_nil(swan_island_tandem_bar_result, 'Tandem results should count in Team BAR')
    assert_equal(12.5, swan_island_tandem_bar_result.points, 'Kona Tandem BAR points')

    ncc_team_result = team_bar_race.results.detect do |result|
      result.team.name == 'Northampton Cycling Club'
    end
    assert_nil(ncc_team_result, 'No tandem BAR result for NCC because it is not an OBRA member')
  end
  
  def test_standings_discipline
    mt_hood_1 = events(:mt_hood_1)
    tt_stage = mt_hood_1.standings.create(:name => 'Rowena Time Trial', :event => mt_hood_1, :discipline => 'Time Trial', :date => Date.new(2005, 7))
    womens_tt = tt_stage.races.create(:standings => tt_stage, :category => categories(:sr_women), :field_size => 6)
    leah = Racer.create(:name => 'Leah Goodchek')
    womens_tt.results.create(:racer => leah, :place => '3')
    
    road_stage = mt_hood_1.standings.create(:name => 'Cooper Spur RR', :event => mt_hood_1, :date => Date.new(2005, 7))
    senior_men_road_stage = road_stage.races.create(:standings => road_stage, :category => categories(:sr_p_1_2), :field_size => 6)
    tuft = Racer.create(:name => 'Svein Tuft')
    senior_men_road_stage.results.create(:racer => tuft, :place => '2')
    
    mt_hood_2 = events(:mt_hood_2)
    womens_road_stage = mt_hood_2.standings.create(:name => 'Womens Cooper Spur RR', :event => mt_hood_2, :discipline => 'Road', :date => Date.new(2005, 7))
    senior_women_road_stage = road_stage.races.create(:standings => womens_road_stage, :category => categories(:sr_women), :field_size => 6)
    senior_women_road_stage.results.create(:racer => leah, :place => '15')
    
    Bar.recalculate(2005)
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2005)])

    standings = bar.standings.detect{|standings| standings.name == 'Time Trial'}
    race = standings.races.detect {|race| race.bar_category == categories(:senior_women_bar)}
    leah_tt_bar_result = race.results.detect {|result| result.racer == leah}
    assert_equal(22, leah_tt_bar_result.points, 'Leah TT BAR points')

    leah_road_bar_result = bar.standings.detect{|s| s.name == 'Road'}.races.detect {|r| r.bar_category == categories(:senior_women_bar)}.results.detect {|r| r.racer == leah}
    assert_equal(1, leah_road_bar_result.points, 'Leah Road BAR points')

    svein_road_bar_result = bar.standings.detect{|s| s.name == 'Road'}.races.detect {|r| r.bar_category == categories(:senior_men_bar)}.results.detect {|r| r.racer == tuft}
    assert_equal(25, svein_road_bar_result.points, 'Svein Road BAR points')  
  end
  
  def test_racers_best_result_for_each_race
    scoring_results = []
    best_results = Bar.racers_best_result_for_each_race(scoring_results)
    assert_equal_enumerables([], best_results, 'Empty results should not change')
    
    scoring_results = [results(:tonkin_banana_belt), results(:weaver_kings_valley)]
    best_results = Bar.racers_best_result_for_each_race(scoring_results)
    assert_equal_enumerables([results(:tonkin_banana_belt), results(:weaver_kings_valley)], best_results, 'No changes with no duplicate results')
    
    scoring_results = [results(:tonkin_banana_belt), results(:weaver_kings_valley), results(:weaver_jack_frost)]
    best_results = Bar.racers_best_result_for_each_race(scoring_results)
    assert_equal_enumerables([results(:tonkin_banana_belt), results(:weaver_kings_valley), results(:weaver_jack_frost)], best_results, 'No changes with no duplicate results')
    
    dupe_tonkin_kings_valley = races(:kings_valley_pro_1_2).results.create(:racer => racers(:tonkin), :place => 13)
    dupe_weaver_kings_valley = races(:kings_valley_pro_1_2).results.create(:racer => racers(:weaver), :place => 13)
    scoring_results = [
      results(:tonkin_banana_belt),
      dupe_tonkin_kings_valley, 
      results(:tonkin_kings_valley), 
      results(:weaver_jack_frost),
      dupe_weaver_kings_valley,
      results(:weaver_kings_valley)]
    best_results = Bar.racers_best_result_for_each_race(scoring_results)
    expected = [dupe_tonkin_kings_valley, dupe_weaver_kings_valley, results(:tonkin_banana_belt), results(:weaver_jack_frost)]
    assert_equal_enumerables(expected, best_results, 'Should remove Tonkin dupe result in 13th')
  end
  
  def test_pick_best_juniors_for_overall
    expert_junior_men = categories(:expert_junior_men)
    junior_men = categories(:junior_men)
    sport_junior_men = categories(:sport_junior_men)

    # Masters too
    marin_knobular = SingleDayEvent.create(:name => 'Marin Knobular', :date => Date.new(2001, 9, 7), :discipline => 'Mountain Bike')
    standings = marin_knobular.standings.create
    race = standings.races.create!(:category => expert_junior_men, :field_size => 6)
    kc = Racer.create(:name => 'KC Mautner')
    vanilla = teams(:vanilla)
    race.results.create(:racer => kc, :place => 4, :team => vanilla)
    chris_woods = Racer.create(:name => 'Chris Woods')
    gentle_lovers = teams(:gentle_lovers)
    race.results.create(:racer => chris_woods, :place => 12, :team => gentle_lovers)
    
    lemurian = SingleDayEvent.create(:name => 'Lemurian', :date => Date.new(2001, 9, 14), :discipline => 'Mountain Bike')
    standings = marin_knobular.standings.create
    race = standings.races.create!(:category => sport_junior_men, :field_size => 6)
    race.results.create(:racer => chris_woods, :place => 14, :team => gentle_lovers)
    
    Bar.recalculate(2001)
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2001, 1, 1)])
    assert_not_nil(bar, "2001 Bar after recalculate")
    assert_equal(1, Bar.count, "Bar events after recalculate")
    assert_equal(8, bar.standings.count, "Bar standings after recalculate")
    assert_equal(21, Result.count, "Total count of results in DB")

    mtb_bar = bar.standings.detect do |standings|
      standings.name == 'Mountain Bike'
    end
    expert_junior_men_mtb_bar = mtb_bar.races.detect do |race|
      race.category == expert_junior_men
    end
    expert_junior_men_mtb_bar.results.sort!
    assert_equal(2, expert_junior_men_mtb_bar.results.size, 'Expert Junior Men BAR results')
    assert_equal(kc, expert_junior_men_mtb_bar.results.first.racer, 'Expert Junior Men BAR first result')
    assert_equal(19, expert_junior_men_mtb_bar.results.first.points, 'Expert Junior Men BAR first points')
    assert_equal(chris_woods, expert_junior_men_mtb_bar.results.last.racer, 'Expert Junior Men BAR last result')
    assert_equal(4, expert_junior_men_mtb_bar.results.last.points, 'Expert Junior Men BAR last points')
    
    sport_junior_men_mtb_bar = mtb_bar.races.detect do |race|
      race.category == sport_junior_men
    end
    assert_equal(1, sport_junior_men_mtb_bar.results.size, 'Sport Junior Men BAR results')
    assert_equal(chris_woods, sport_junior_men_mtb_bar.results.first.racer, 'Sport Junior Men BAR last result')
    assert_equal(2, sport_junior_men_mtb_bar.results.last.points, 'Sport Junior Men BAR first points')
    
    junior_men_mtb_bar = mtb_bar.races.detect do |race|
      race.category == junior_men
    end
    assert_nil(junior_men_mtb_bar, 'No combined Junior MTB BAR')
    
    overall_bar = bar.standings.detect do |standings|
      standings.name == 'Overall'
    end
    overall_junior_men_mtb_bar = overall_bar.races.detect do |race|
      race.category == junior_men
    end
    assert_equal(2, overall_junior_men_mtb_bar.results.size, 'Overall Junior Men BAR results')
    overall_junior_men_mtb_bar.results.sort! {|x, y| x.racer <=> y.racer}
    assert_equal(kc, overall_junior_men_mtb_bar.results.first.racer, 'Overall Junior Men BAR first result')
    assert_equal(chris_woods, overall_junior_men_mtb_bar.results.last.racer, 'Overall Junior Men BAR last result')
    assert_equal(300, overall_junior_men_mtb_bar.results.first.points, 'Overall Junior Men BAR first points')
    assert_equal(300, overall_junior_men_mtb_bar.results.last.points, 'Overall Junior Men BAR last points')
    
    team_bar = bar.standings.detect do |standings|
      standings.name == 'Team'
    end
    team_bar = team_bar.races.first
    team_bar.results.sort!
    assert_equal(2, team_bar.results.size, 'Team BAR results')
    assert_equal(vanilla, team_bar.results.first.team, 'Team BAR first result')
    assert_equal(19, team_bar.results.first.points, 'Team BAR first points')
    assert_equal(gentle_lovers, team_bar.results.last.team, 'Team BAR last result')
    assert_equal(6, team_bar.results.last.points, 'Team BAR last points')
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
  
  def test_field_size
    cross_crusade = Series.create!(:name => "Cross Crusade")

    # Large event
    barton = SingleDayEvent.create!({
      :name => "Cross Crusade: Barton Park",
      :discipline => "Cyclocross",
      :date => Date.new(2009, 11, 7),
      :parent => cross_crusade
    })
    barton_standings = barton.standings.create
    men_a = Category.find_association("Men A")
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
    assert_equal(33 + 30 + 21, tonkin_bar_result.points, 'Tonkin BAR points')
    weaver_bar_result = men_a_bar.results.last
    assert_equal(racers(:weaver), weaver_bar_result.racer)
    assert_equal(1.5 + 11, weaver_bar_result.points, 'Weaver BAR points')
    
    overall_bar = bar.standings.detect do |standings|
      standings.name == 'Overall'
    end
    
    overall_sr_men_bar = overall_bar.races.detect do |race|
      race.name == 'Senior Men'
    end
    
    assert_not_nil(overall_sr_men_bar, 'Senior Men Overall BAR')
    assert_equal(2, overall_sr_men_bar.results.size, 'Senior Men BAR results')

    overall_sr_men_bar.results.sort!
    tonkin_bar_result = overall_sr_men_bar.results.first
    assert_equal(racers(:tonkin), tonkin_bar_result.racer)
    assert_equal(350, tonkin_bar_result.points, 'Tonkin Overall BAR points')
    weaver_bar_result = overall_sr_men_bar.results.last
    assert_equal(racers(:weaver), weaver_bar_result.racer)
    assert_equal(299, weaver_bar_result.points, 'Weaver Overall BAR points')

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
    assert_equal(0, tonkin_bar_result.points, 'Tonkin Crit BAR points')
  end
  
  def test_set_bonus_points_for_extra_disciplines
    # empty
    scores = []
    Bar.set_bonus_points_for_extra_disciplines(scores)
    
    # One result with points
    weaver = racers(:weaver)
    bar = Bar.create
    track_bar = bar.standings.create!(:name => 'Track', :discipline => 'Track')
    junior_men_track_bar = track_bar.races.create!(:category => categories(:junior_men))
    discipline_source_result = junior_men_track_bar.results.create!(:racer => weaver, :place => 10, :points => 73)
    
    overall_bar = bar.standings.create!(:name => 'Overall', :discipline => 'Overall')
    overall_jr_men_bar = overall_bar.races.create!(:category => categories(:junior_men))
    overall_bar_result = overall_jr_men_bar.results.create!(:place => 42, :points => 291)

    score_with_discipline_points = overall_bar_result.scores.create(
      :source_result => discipline_source_result, 
      :competition_result => overall_bar_result, 
      :points => 291)
    scores = [score_with_discipline_points]
    Bar.set_bonus_points_for_extra_disciplines(scores)
    score_with_discipline_points.reload
    assert_equal(291, score_with_discipline_points.points, 'score_with_discipline_points points')
  end
  
  def test_set_bonus_points_for_extra_disciplines_bonus_result_with_high_placing
    bar = Bar.create
    track_bar = bar.standings.create!(:name => 'Track', :discipline => 'Track')
    junior_men_track_bar = track_bar.races.create!(:category => categories(:junior_men))
    overall_bar = bar.standings.create!(:name => 'Overall', :discipline => 'Overall')
    overall_jr_men_bar = overall_bar.races.create!(:category => categories(:junior_men))
    overall_bar_result = overall_jr_men_bar.results.create!(:place => 42, :points => 291)

    # One result with only no discipline points
    discipline_source_result = junior_men_track_bar.results.create!(:racer => racers(:tonkin), :place => 3, :points => 0)
    overall_bar_result = overall_jr_men_bar.results.create!(:place => 8, :points => 50)

    score_with_discipline_bonus_only = overall_bar_result.scores.create(
      :source_result => discipline_source_result, 
      :competition_result => overall_bar_result, 
      :points => 50)
    scores = [score_with_discipline_bonus_only]
    Bar.set_bonus_points_for_extra_disciplines(scores)
    score_with_discipline_bonus_only.reload
    assert_equal(50, score_with_discipline_bonus_only.points, 'score_with_discipline_bonus_only points')
    
    # 0-point discipline result (bonus only) with higher place than discipline results with points
    discipline_source_result = junior_men_track_bar.results.create!(:racer => racers(:alice), :place => 3, :points => 0)
    overall_bar_result = overall_jr_men_bar.results.create!(:place => 8)
    score_with_discipline_bonus_only = overall_bar_result.scores.create(
      :source_result => discipline_source_result, 
      :competition_result => overall_bar_result, 
      :points => 50)
      
    road_bar = bar.standings.create!(:name => 'Road', :discipline => 'Road')
    junior_men_road_bar = road_bar.races.create!(:category => categories(:junior_men))
    discipline_source_result = junior_men_road_bar.results.create!(:racer => racers(:alice), :place => 10, :points => 73)
    road_score = overall_bar_result.scores.create(
      :source_result => discipline_source_result, 
      :competition_result => overall_bar_result, 
      :points => 291)
    
    mtb_bar = bar.standings.create!(:name => 'MTB', :discipline => 'Mountain Bike')
    junior_men_mtb_bar = mtb_bar.races.create!(:category => categories(:junior_men))
    discipline_source_result = junior_men_mtb_bar.results.create!(:racer => racers(:alice), :place => 11, :points => 123)
    mtb_score = overall_bar_result.scores.create(
      :source_result => discipline_source_result, 
      :competition_result => overall_bar_result, 
      :points => 290)

    tt_bar = bar.standings.create!(:name => 'Time Trial', :discipline => 'Time Trial')
    junior_men_tt_bar = tt_bar.races.create!(:category => categories(:junior_men))
    discipline_source_result = junior_men_tt_bar.results.create!(:racer => racers(:alice), :place => 4, :points => 1)
    tt_score = overall_bar_result.scores.create(
      :source_result => discipline_source_result, 
      :competition_result => overall_bar_result, 
      :points => 297)

    crit_bar = bar.standings.create!(:name => 'Criterium', :discipline => 'Criterium')
    junior_men_crit_bar = crit_bar.races.create!(:category => categories(:junior_men))
    discipline_source_result = junior_men_crit_bar.results.create!(:racer => racers(:alice), :place => 5, :points => 124)
    crit_score = overall_bar_result.scores.create(
      :source_result => discipline_source_result, 
      :competition_result => overall_bar_result, 
      :points => 296)

    scores = [score_with_discipline_bonus_only, tt_score, crit_score, road_score, mtb_score]
    assert_equal(5, scores.size, 'Scores size before set_bonus_points_for_extra_disciplines')
    Bar.set_bonus_points_for_extra_disciplines(scores)
    assert_equal(5, scores.size, 'Scores size after set_bonus_points_for_extra_disciplines')

    for score in scores
      score.reload
    end
    assert_equal(297, tt_score.points, 'tt_score points')
    assert_equal(296, crit_score.points, 'crit_score points')
    assert_equal(291, road_score.points, 'road_score points')
    assert_equal(290, mtb_score.points, 'mtb_score points')
    assert_equal(50, score_with_discipline_bonus_only.points, 'score_with_discipline_bonus_only points')
  end
  
  def test_result_key
    key_1 = ResultKey.new(results(:tonkin_banana_belt))
    key_2 = ResultKey.new(results(:tonkin_banana_belt))    
    assert_equal(key_1, key_2, 'Same result')
    assert_equal(key_1.hash, key_2.hash, 'Same result')
    assert_equal(0, key_1 <=> key_2, 'same diff')
    assert(key_1 == key_2)
    assert(key_1 == key_1)
    assert(key_2 == key_2)
    assert(key_1.eql?(key_2))
    assert(key_2.eql?(key_1))
    assert(key_1.eql?(key_1))
    assert(key_2.eql?(key_2))

    hash = {}
    hash[key_1] = 'key 1 value'
    assert(hash[key_1])
    assert(hash[key_2])
    
    key_1 = ResultKey.new(results(:tonkin_banana_belt))
    key_2 = ResultKey.new(results(:weaver_kings_valley))    
    assert(key_1 != key_2, 'Different results')
    assert(key_1.hash != key_2.hash, 'Different results')
    assert((key_1 <=> key_2) != 0, 'Different results')
    assert(key_1 != key_2)
    assert(key_1 == key_1)
    assert(key_2 == key_2)
    assert(!key_1.eql?(key_2))
    assert(!key_2.eql?(key_1))
    assert(key_1.eql?(key_1))
    assert(key_1.eql?(key_1))

    key_1 = ResultKey.new(results(:tonkin_banana_belt))
    dupe_tonkin_kings_valley = races(:banana_belt_pro_1_2).results.create(:racer => racers(:tonkin), :place => 13)
    key_2 = ResultKey.new(dupe_tonkin_kings_valley)    
    assert_equal(key_1, key_2, 'Same racer and same race')
    assert_equal(key_1.hash, key_2.hash, 'Same result')
    assert_equal(0, key_1 <=> key_2, 'same diff')
    assert(key_1 == key_2)
    assert(key_1 == key_1)
    assert(key_2 == key_2)
    assert(key_1.eql?(key_2))
    assert(key_2.eql?(key_1))
    assert(key_1.eql?(key_1))
    assert(key_2.eql?(key_2))

    hash = {}
    hash[key_1] = 'key 1 value'
    assert(hash[key_1])
    assert(hash[key_2])
  end
end