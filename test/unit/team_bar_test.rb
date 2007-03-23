require File.dirname(__FILE__) + '/../test_helper'

class TeamBarTest < Test::Unit::TestCase
  def test_recalculate_tandem
    tandem = Category.create(:name => "Tandem")
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
  
end