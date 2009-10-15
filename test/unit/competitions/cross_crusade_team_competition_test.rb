require "test_helper"

# test_overall_team_competition_living_together
# member teams only
# What if nobody races? 1,000 points!
# Test display
class CrossCrusadeTeamCompetitionTest < ActiveSupport::TestCase  
  def test_recalc_with_no_series
    competition_count = Competition.count
    CrossCrusadeTeamCompetition.calculate!
    CrossCrusadeTeamCompetition.calculate!(2007)
    assert_equal competition_count, Competition.count, "Should add no new Competition if there are no Cross Crusade events"
  end

  def test_recalc_with_one_event
    series = Series.create!(:name => "Cross Crusade")
    event = series.children.create!(:date => Date.new(2007, 10, 7))

    series.children.create! :date => Date.new(2007, 10, 14)
    series.children.create! :date => Date.new(2007, 10, 21)
    series.children.create! :date => Date.new(2007, 10, 28)
    series.children.create! :date => Date.new(2007, 11, 5)

    cat_a = Category.find_or_create_by_name("Category A")
    cat_a_race = event.races.create!(:category => cat_a)
    cat_a_race.results.create! :place => 5, :person => people(:weaver), :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 7, :person => people(:tonkin), :team => teams(:kona)
    cat_a_race.results.create! :place => 8, :person => people(:alice), :team => teams(:kona)
    cat_a_race.results.create! :place => "", :person =>Person.create!, :team => teams(:gentle_lovers)

    cat_b = Category.find_or_create_by_name("Category B")
    cat_b_race = event.races.create!(:category => cat_b)
    cat_b_race.results.create! :place => 9, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 10, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 11, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 12, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 14, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 15, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 17, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 20, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 30, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => "DQ", :person => Person.create!, :team => teams(:vanilla)

    cat_c = Category.find_or_create_by_name("Category C")
    cat_c_race = event.races.create!(:category => cat_c)
    cat_c_race.results.create! :place => 1, :person => Person.create!, :team => teams(:vanilla)
    cat_c_race.results.create! :place => 2, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_c_race.results.create! :place => 3, :person => Person.create!, :team => teams(:kona)
    cat_c_race.results.create! :place => 5, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_c_race.results.create! :place => 6, :person => Person.create!, :team => teams(:kona)
    cat_c_race.results.create! :place => 7, :person => Person.create!, :team => teams(:vanilla)
    cat_c_race.results.create! :place => 8, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_c_race.results.create! :place => 9, :person => Person.create!, :team => teams(:kona)
    cat_c_race.results.create! :place => 104, :person => Person.create!, :team => teams(:vanilla)
    cat_c_race.results.create! :place => "DNF", :person => Person.create!, :team => teams(:kona)

    assert_equal 0, series.child_competitions.count, "Cross Crusade competitions"
    CrossCrusadeTeamCompetition.calculate! 2007
    assert_equal 1, series.child_competitions.count, "Cross Crusade competitions"
    team_competition = series.child_competitions.first
    assert_equal 1, team_competition.races.size, "team_competition races"
    CrossCrusadeTeamCompetition.calculate! 2007
    assert_equal 1, series.child_competitions.count, "Cross Crusade competitions"
    team_competition = series.child_competitions.first
    assert_equal 1, team_competition.races.size, "team_competition races"

    assert_equal "Team Competition", team_competition.name, "name"
    assert_equal "Cross Crusade: Team Competition", team_competition.full_name, "full name"
    assert !team_competition.notes.blank?, "Should have notes about rules"

    assert_equal_dates Date.new(2007, 10, 7), team_competition.date, "team_competition series date"
    assert_equal_dates Date.new(2007, 10, 7), team_competition.start_date, "team_competition series start date"
    assert_equal_dates Date.new(2007, 11, 5), team_competition.end_date, "team_competition series end date"

    race = team_competition.races.detect { |race| race.category == Category.find_or_create_by_name("Team") }
    assert_not_nil(race, "Should have team race")
    assert_equal(3, race.results.size, "race results")
    assert_equal %W{ place team_name points }, race.result_columns, "result_columns"

    race.results(true).sort!
    result = race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "first result place")
    assert_equal teams(:gentle_lovers), result.team, "first result team"
    assert_equal(91, result.points, "first result points")
    assert_equal 10, result.scores.count, "first result scores"

    result = race.results[1]
    assert_equal("2", result.place, "second result place")
    assert_equal teams(:kona), result.team, "second result team"
    assert_equal(533, result.points, "second result points")
    assert_equal 7, result.scores.count, "second result scores"

    result = race.results[2]
    assert_equal("3", result.place, "third result place")
    assert_equal teams(:vanilla), result.team, "third result team"
    assert_equal(808, result.points, "third result points")
    assert_equal 5, result.scores.count, "third result scores"
  end
  
  def test_missing_teams_penalty
    series = Series.create!(:name => "Cross Crusade")
    series.children.create! :date => Date.new(2007, 10, 7)
    series.children.create! :date => Date.new(2007, 10, 14)
    series.children.create! :date => Date.new(2007, 10, 21)

    cat_a = Category.find_or_create_by_name("Category A")
    cat_a_race = series.children[0].races.create!(:category => cat_a)
    cat_a_race.results.create! :place => 1, :person => people(:alice), :team => teams(:kona)
    non_member_team = Team.create!(:name => "No Member")
    assert !non_member_team.member?, "member?"
    cat_a_race.results.create! :place => 2, :person => people(:alice), :team => non_member_team
    cat_a_race.results.create! :place => 3, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 7, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 11, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 15, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 19, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => "", :person => Person.create!, :team => teams(:gentle_lovers)

    cat_b = Category.find_or_create_by_name("Category B")
    cat_b_race = series.children[0].races.create!(:category => cat_b)
    cat_b_race.results.create! :place => 3, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 8, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 13, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 18, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_b_race.results.create! :place => 23, :person => Person.create!, :team => teams(:gentle_lovers)

    cat_a_race = series.children[1].races.create!(:category => cat_a)
    cat_a_race.results.create! :place => 7, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 14, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 21, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 22, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 28, :person => Person.create!, :team => teams(:gentle_lovers)
    cat_a_race.results.create! :place => 200, :person => Person.create!, :team => teams(:gentle_lovers)

    cat_b_race = series.children[1].races.create!(:category => cat_b)
    cat_b_race.results.create! :place => 11, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 12, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 13, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 14, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 15, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 16, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 17, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 18, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 19, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 20, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 21, :person => Person.create!, :team => teams(:vanilla)
    cat_b_race.results.create! :place => 22, :person => Person.create!, :team => teams(:vanilla)

    CrossCrusadeTeamCompetition.calculate! 2007

    team_competition = series.child_competitions.first

    race = team_competition.races.detect { |race| race.category == Category.find_or_create_by_name("Team") }
    assert_not_nil(race, "Should have team race")
    assert_equal(3, race.results.size, "race results")

    race.results(true).sort!
    result = race.results.first
    assert_equal("1", result.place, "first result place")
    assert_equal teams(:gentle_lovers), result.team, "first result team"
    assert_equal 712, result.points, "first result points"
    assert_equal 17, result.scores.count, "first result scores"

    result = race.results[1]
    assert_equal("2", result.place, "second result place")
    assert_equal teams(:vanilla), result.team, "third result team"
    assert_equal 1155, result.points, "third result points"
    assert_equal 11, result.scores.count, "third result scores"

    result = race.results[2]
    assert_equal("3", result.place, "third result place")
    assert_equal teams(:kona), result.team, "second result team"
    assert_equal(1901, result.points, "second result points")
    assert_equal 3, result.scores.count, "second result scores"
  end
end
