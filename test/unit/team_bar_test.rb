# There is duplication between BAR tests, but refactring the tests should wait until the Competition refactoring is complete

require File.dirname(__FILE__) + '/../test_helper'

class TeamTeamBarTest < Test::Unit::TestCase
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
    TeamBar.recalculate(2004)
    bar = TeamBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 TeamBar after recalculate")
    team_bar_race = bar.standings.first.races.first
    
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
    TeamBar.recalculate(2001)
    bar = TeamBar.find(:first, :conditions => ['date = ?', Date.new(2001, 1, 1)])
    team_bar = bar.standings.first.races.first
    
    team_bar.results.sort!
    assert_equal(2, team_bar.results.size, 'Team BAR results')
    assert_equal(vanilla, team_bar.results.first.team, 'Team BAR first result')
    assert_equal(19, team_bar.results.first.points, 'Team BAR first points')
    assert_equal(gentle_lovers, team_bar.results.last.team, 'Team BAR last result')
    assert_equal(6, team_bar.results.last.points, 'Team BAR last points')
  end
  
  def test_recalculate
    # Lot of set-up for BAR. Keep it out of fixtures and do one-time here.
    
    cross_crusade = Series.create!(:name => "Cross Crusade")
    barton = SingleDayEvent.create!({
      :name => "Cross Crusade: TeamBarton Park",
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
      :racer => racers(:mollie)
    })
    senior_women = Category.find_by_name("Senior Women")
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
    assert_equal(0, TeamBar.count, "TeamBar standings before recalculate")
    assert_equal(27, Result.count, "Total count of results in DB before BAR recalculate")
    Bar.recalculate(2004)
    TeamBar.recalculate(2004)
    assert_equal(1, TeamBar.count, "TeamBar events after recalculate")
    bar = TeamBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 TeamBar after recalculate")
    assert_equal(1, bar.standings.count, "TeamBar standings after recalculate")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 TeamBar date")
    assert_equal("2004 Team BAR", bar.name, "2004 Team Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "BAR last updated")
    assert_equal(45, Result.count, "Total count of results in DB")
    
    team_standings = bar.standings.first
    assert_equal(1, team_standings.races.size, 'Should have only one team BAR standings race')
    team_race = team_standings.races.first
    
    assert_equal(3, team_race.results.size, "Team BAR results")
    assert_equal_dates(Date.today, team_race.updated_at, "BAR last updated")

    team_race.results.sort!
    assert_equal(teams(:kona), team_race.results[0].team, "Team BAR results team")
    assert_equal("1", team_race.results[0].place, "Team BAR results place")
    assert_in_delta(97, team_race.results[0].points, 0.0, "Team BAR results points")

    assert_equal(teams(:gentle_lovers), team_race.results[1].team, "Team BAR results team")
    assert_equal("2", team_race.results[1].place, "Team BAR results place")
    assert_equal(25, team_race.results[1].points, "Team BAR results points")

    assert_equal(teams(:vanilla), team_race.results[2].team, "Team BAR results team")
    assert_equal("3", team_race.results[2].place, "Team BAR results place")
    assert_equal(1, team_race.results[2].points, "Team BAR results points")

    # check placings for ties
    # remove one-day licensees
  end
  
end