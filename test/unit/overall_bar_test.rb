# There is duplication between BAR tests, but refactring the tests should wait until the Competition refactoring is complete

require File.dirname(__FILE__) + '/../test_helper'

class OverallBarTest < Test::Unit::TestCase
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
    swan_island_senior_men = swan_island_standings.races.create(:category => senior_men, :field_size => 4)
    swan_island_senior_men.results.create({
      :place => 12,
      :racer => racers(:tonkin)
    })
    swan_island_senior_men.results.create({
      :place => 2,
      :racer => racers(:mollie)
    })
    senior_women = Category.find_association("Senior Women")
    senior_women_swan_island = swan_island_standings.races.create(:category => senior_women, :field_size => 3)
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
    tandem = Category.create(:name => "Tandem")
    crit_discipline = disciplines(:criterium)
    crit_discipline.bar_categories << tandem
    crit_discipline.save!
    assert(overall_discipline.bar_categories.include?(tandem), 'Overall Discipline should include Tandem category')
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

  def test_pick_best_juniors_for_overall
    expert_junior_men = categories(:expert_junior_men)
    junior_men = categories(:junior_men)
    sport_junior_men = categories(:sport_junior_men)

    # Masters too
    marin_knobular = SingleDayEvent.create(:name => 'Marin Knobular', :date => Date.new(2001, 9, 7), :discipline => 'Mountain Bike')
    standings = marin_knobular.standings.create
    race = standings.races.create(:category => expert_junior_men)
    kc = Racer.create(:name => 'KC Mautner', :member_from => Date.new(2001, 1, 1))
    vanilla = teams(:vanilla)
    race.results.create(:racer => kc, :place => 4, :team => vanilla)
    chris_woods = Racer.create(:name => 'Chris Woods', :member_from => Date.new(2001, 1, 1))
    gentle_lovers = teams(:gentle_lovers)
    race.results.create(:racer => chris_woods, :place => 12, :team => gentle_lovers)
    
    lemurian = SingleDayEvent.create(:name => 'Lemurian', :date => Date.new(2001, 9, 14), :discipline => 'Mountain Bike')
    standings = marin_knobular.standings.create
    race = standings.races.create(:category => sport_junior_men)
    race.results.create(:racer => chris_woods, :place => 14, :team => gentle_lovers)
    
    Bar.recalculate(2001)
    bar = Bar.find(:first, :conditions => ['date = ?', Date.new(2001, 1, 1)])
    assert_not_nil(bar, "2001 Bar after recalculate")
    assert_equal(1, Bar.count, "Bar events after recalculate")
    assert_equal(8, bar.standings.count, "Bar standings after recalculate")
    p bar.inspect
    # Just missing team result?
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
    assert_equal(33 + 30 + 25 + 21, tonkin_bar_result.points, 'Tonkin BAR points')
    weaver_bar_result = men_a_bar.results.last
    assert_equal(racers(:weaver), weaver_bar_result.racer)
    assert_equal(1.5 + 11 + 22, weaver_bar_result.points, 'Weaver BAR points')
    
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
    assert_equal(600, tonkin_bar_result.points, 'Tonkin Overall BAR points')
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
    assert_not_nil(standings.first.races(true).first.category.category, 'BAR Category')
    
    # Calculate previous years' BAR
    Bar.recalculate(previous_year)
    previous_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    
    # Assert it has results
    previous_year_overall_bar = previous_year_bar.standings.detect do |standings|
      standings.name == 'Overall'
    end
    previous_year_sr_men_overall_bar = previous_year_overall_bar.races.detect {|race| race.category == categories(:senior_men_bar)}
    assert(!previous_year_sr_men_overall_bar.results.empty?, 'Previous year BAR should have results')
    
    # Create result for this year
    current_year_event = SingleDayEvent.create(:date => Date.new(current_year, 7, 20), :discipline => 'Road')
    current_year_event.reload
    assert_equal('Road', current_year_event.discipline, 'Event discipline')
    current_year_result = current_year_event.standings.create.races.create(:category => categories(:sr_p_1_2)).results.create(:place => '13', :racer => weaver)

    # Calculate this years' BAR
    Bar.recalculate(current_year)

    # Assert both BARs have results
    previous_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    previous_year_overall_bar = previous_year_bar.standings.detect do |standings|
      standings.name == 'Overall'
    end
    previous_year_sr_men_overall_bar = previous_year_overall_bar.races.detect {|race| race.category == categories(:senior_men_bar)}
    assert(!previous_year_sr_men_overall_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(current_year, 1, 1)])
    current_year_overall_bar = current_year_bar.standings.detect do |standings|
      standings.name == 'Overall'
    end
    current_year_sr_men_overall_bar = current_year_overall_bar.races.detect {|race| race.category == categories(:senior_men_bar)}
    assert(!current_year_sr_men_overall_bar.results.empty?, 'Current year BAR should have results')

    # Recalc both BARs
    Bar.recalculate(previous_year)
    Bar.recalculate(current_year)

    # Assert both BARs have results
    previous_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(previous_year, 1, 1)])
    previous_year_overall_bar = previous_year_bar.standings.detect do |standings|
      standings.name == 'Overall'
    end
    previous_year_sr_men_overall_bar = previous_year_overall_bar.races.detect {|race| race.category == categories(:senior_men_bar)}
    assert(!previous_year_sr_men_overall_bar.results.empty?, 'Previous year BAR should have results')
    
    current_year_bar = Bar.find(:first, :conditions => ['date = ?', Date.new(current_year, 1, 1)])
    current_year_overall_bar = current_year_bar.standings.detect do |standings|
      standings.name == 'Overall'
    end
    current_year_sr_men_overall_bar = current_year_overall_bar.races.detect {|race| race.category == categories(:senior_men_bar)}
    assert(!current_year_sr_men_overall_bar.results.empty?, 'Current year BAR should have results')
  end
  
end