require File.expand_path("../../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class CrossCrusadeTeamCompetitionTest < ActiveSupport::TestCase
    test "recalc with one event" do
      weaver = FactoryGirl.create(:person)
      tonkin = FactoryGirl.create(:person)
      alice = FactoryGirl.create(:person)

      gentle_lovers = FactoryGirl.create(:team)
      kona = FactoryGirl.create(:team)
      vanilla = FactoryGirl.create(:team)

      series = Series.create!(name: "Cross Crusade")
      event = series.children.create!(date: Date.new(2007, 10, 7))

      series.children.create! date: Date.new(2007, 10, 14)
      series.children.create! date: Date.new(2007, 10, 21)
      series.children.create! date: Date.new(2007, 10, 28)
      series.children.create! date: Date.new(2007, 11, 5)

      cat_a = Category.find_or_create_by(name: "Category A")
      cat_a_race = event.races.create!(category: cat_a)
      cat_a_race.results.create! place: 5, person: weaver, team: gentle_lovers
      cat_a_race.results.create! place: 7, person: tonkin, team: kona
      cat_a_race.results.create! place: 8, person: alice, team: kona
      cat_a_race.results.create! place: "", person:Person.create!, team: gentle_lovers

      cat_b = Category.find_or_create_by(name: "Category B")
      cat_b_race = event.races.create!(category: cat_b)
      cat_b_race.results.create! place: 9, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 10, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 11, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 12, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 14, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 15, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 17, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 20, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 30, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: "DQ", person: Person.create!, team: vanilla

      cat_c = Category.find_or_create_by(name: "Category C")
      cat_c_race = event.races.create!(category: cat_c)
      cat_c_race.results.create! place: 1, person: Person.create!, team: vanilla
      cat_c_race.results.create! place: 2, person: Person.create!, team: gentle_lovers
      cat_c_race.results.create! place: 3, person: Person.create!, team: kona
      cat_c_race.results.create! place: 5, person: Person.create!, team: gentle_lovers
      cat_c_race.results.create! place: 6, person: Person.create!, team: kona
      cat_c_race.results.create! place: 7, person: Person.create!, team: vanilla
      cat_c_race.results.create! place: 8, person: Person.create!, team: gentle_lovers
      cat_c_race.results.create! place: 9, person: Person.create!, team: kona
      cat_c_race.results.create! place: 104, person: Person.create!, team: vanilla
      cat_c_race.results.create! place: "DNF", person: Person.create!, team: kona

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

      race = team_competition.races.detect { |r| r.category == Category.find_or_create_by(name: "Team") }
      assert_not_nil(race, "Should have team race")
      assert_equal(3, race.results.size, "race results")
      assert_equal %W{ place team_name points }, race.result_columns, "result_columns"

      results = race.results(true).sort
      result = results.first
      assert_equal(false, result.preliminary?, "Preliminary?")
      assert_equal("1", result.place, "first result place")
      assert_equal gentle_lovers, result.team, "first result team"
      assert_equal(91, result.points, "first result points")
      assert_equal 10, result.scores.count, "first result scores"

      result = results[1]
      assert_equal("2", result.place, "second result place")
      assert_equal kona, result.team, "second result team"
      assert_equal(533, result.points, "second result points")
      assert_equal 7, result.scores.count, "second result scores"

      result = results[2]
      assert_equal("3", result.place, "third result place")
      assert_equal vanilla, result.team, "third result team"
      assert_equal(808, result.points, "third result points")
      assert_equal 5, result.scores.count, "third result scores"
    end

    test "missing teams penalty" do
      alice = FactoryGirl.create(:person)

      gentle_lovers = FactoryGirl.create(:team)
      kona = FactoryGirl.create(:team)
      vanilla = FactoryGirl.create(:team)

      series = Series.create!(name: "Cross Crusade")
      series.children.create! date: Date.new(2007, 10, 7)
      series.children.create! date: Date.new(2007, 10, 14)
      series.children.create! date: Date.new(2007, 10, 21)

      cat_a = Category.find_or_create_by(name: "Category A")
      cat_a_race = series.children[0].races.create!(category: cat_a)
      cat_a_race.results.create! place: 1, person: alice, team: kona
      non_member_team = Team.create!(name: "No Member")
      assert !non_member_team.member?, "member?"
      cat_a_race.results.create! place: 2, person: alice, team: non_member_team
      cat_a_race.results.create! place: 3, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: 7, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: 11, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: 15, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: 19, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: "", person: Person.create!, team: gentle_lovers

      cat_b = Category.find_or_create_by(name: "Category B")
      cat_b_race = series.children[0].races.create!(category: cat_b)
      cat_b_race.results.create! place: 3, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 8, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 13, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 18, person: Person.create!, team: gentle_lovers
      cat_b_race.results.create! place: 23, person: Person.create!, team: gentle_lovers

      cat_a_race = series.children[1].races.create!(category: cat_a)
      cat_a_race.results.create! place: 7, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: 14, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: 21, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: 22, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: 28, person: Person.create!, team: gentle_lovers
      cat_a_race.results.create! place: 200, person: Person.create!, team: gentle_lovers

      cat_b_race = series.children[1].races.create!(category: cat_b)
      cat_b_race.results.create! place: 11, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 12, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 13, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 14, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 15, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 16, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 17, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 18, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 19, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 20, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 21, person: Person.create!, team: vanilla
      cat_b_race.results.create! place: 22, person: Person.create!, team: vanilla

      CrossCrusadeTeamCompetition.calculate! 2007

      team_competition = series.child_competitions.first

      race = team_competition.races.detect { |r| r.category == Category.find_or_create_by(name: "Team") }
      assert_not_nil(race, "Should have team race")
      assert_equal(3, race.results.size, "race results")

      results = race.results(true).to_a.sort
      result = results.first
      assert_equal("1", result.place, "first result place")
      assert_equal gentle_lovers, result.team, "first result team"
      assert_equal 712, result.points, "first result points"
      assert_equal 17, result.scores.count, "first result scores"

      result = results[1]
      assert_equal("2", result.place, "second result place")
      assert_equal vanilla, result.team, "third result team"
      assert_equal 1155, result.points, "third result points"
      assert_equal 11, result.scores.count, "third result scores"

      result = results[2]
      assert_equal("3", result.place, "third result place")
      assert_equal kona, result.team, "second result team"
      assert_equal(1901, result.points, "second result points")
      assert_equal 3, result.scores.count, "second result scores"
    end
  end
end
