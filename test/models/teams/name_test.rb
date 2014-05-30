# coding: utf-8

require File.expand_path("../../../test_helper", __FILE__)

module Teams
  # :stopdoc:
  class NameTest < ActiveSupport::TestCase
    test "name with date" do
      team = Team.create! name: "Tecate-Una Mas"
      team.names.create! name: "Twin Peaks", date: Time.zone.local(2010)
      team.names.create! name: "Team Tecate", date: Time.zone.local(2011)

      assert_equal "Twin Peaks",     team.name(2009)
      assert_equal "Twin Peaks",     team.name(2010)
      assert_equal "Team Tecate",    team.name(2011)
      assert_equal "Tecate-Una Mas",    team.name(2012)
      assert_equal "Tecate-Una Mas", team.name(Time.zone.today)
      assert_equal "Tecate-Una Mas", team.name(Time.zone.today.next_year)
      assert_equal "Tecate-Una Mas", team.name
    end

    test "create new name if there are results from previous year" do
      team = Team.create!(name: "Twin Peaks")
      event = SingleDayEvent.create!(date: 1.years.ago)
      senior_men = FactoryGirl.create(:category)
      old_result = event.races.create!(category: senior_men).results.create!(team: team)
      assert_equal("Twin Peaks", old_result.team_name, "Team name on old result")

      event = SingleDayEvent.create!(date: Time.zone.today)
      result = event.races.create!(category: senior_men).results.create!(team: team)
      assert_equal("Twin Peaks", result.team_name, "Team name on new result")
      assert_equal("Twin Peaks", old_result.team_name, "Team name on old result")

      team.name = "Tecate-Una Mas"
      team.save!

      assert_equal(1, team.names(true).size, "names")

      assert_equal("Twin Peaks", old_result.team_name, "Team name should stay the same on old result")
      assert_equal("Tecate-Una Mas", result.reload.team_name, "Team name should change on this year's result")
    end

    test "results before this year" do
      team = Team.create!(name: "Twin Peaks")
      assert(!team.results_before_this_year?, "results_before_this_year? with no results")

      event = SingleDayEvent.create!(date: Time.zone.today)
      senior_men = FactoryGirl.create(:category)
      result = event.races.create!(category: senior_men).results.create!(team: team)
      assert(!team.results_before_this_year?, "results_before_this_year? with results in this year")

      result.destroy

      event = SingleDayEvent.create!(date: 1.years.ago)
      event.races.create!(category: senior_men).results.create!(team: team)
      team.results_before_this_year?
      assert(team.results_before_this_year?, "results_before_this_year? with results only a year ago")

      event = SingleDayEvent.create!(date: 2.years.ago)
      event.races.create!(category: senior_men).results.create!(team: team)
      team.results_before_this_year?
      assert(team.results_before_this_year?, "results_before_this_year? with several old results")

      event = SingleDayEvent.create!(date: Time.zone.today)
      event.races.create!(category: senior_men).results.create!(team: team)
      team.results_before_this_year?
      assert(team.results_before_this_year?, "results_before_this_year? with results in many years")
    end

    test "rename multiple times" do
      team = Team.create!(name: "Twin Peaks")
      event = SingleDayEvent.create!(date: 3.years.ago)
      senior_men = FactoryGirl.create(:category)
      event.races.create!(category: senior_men).results.create!(team: team)
      assert_equal(0, team.names(true).size, "names")

      team.name = "Tecate"
      team.save!
      assert_equal(1, team.names(true).size, "names")
      assert_equal(1, team.aliases(true).size, "aliases")

      team.name = "Tecate Una Mas"
      team.save!
      assert_equal(1, team.names(true).size, "names")
      assert_equal(2, team.aliases(true).size, "aliases")

      team.name = "Tecate-¡Una Mas!"
      team.save!
      assert_equal(1, team.names(true).size, "names")
      assert_equal(3, team.aliases(true).size, "aliases")

      assert_equal("Tecate-¡Una Mas!", team.name, "New team name")
      assert_equal("Twin Peaks", team.names.first.name, "Old team name")
      assert_equal(Time.zone.today.year - 1, team.names.first.year, "Old team name year")
    end

    test "name date or year" do
      team = FactoryGirl.create(:team, name: "Vanilla")
      team.names.create!(name: "Sacha's Team", year: 2001)
      assert_equal("Sacha's Team", team.name(Date.new(2001, 12, 31)), "name for 2001-12-31")
      assert_equal("Sacha's Team", team.name(Date.new(2001)), "name for 2001-01-01")
      assert_equal("Sacha's Team", team.name(2001), "name for 2001")
    end

    test "multiple names" do
      team = FactoryGirl.create(:team, name: "Vanilla")
      team.names.create!(name: "Mapei", year: 2001)
      team.names.create!(name: "Mapei-Clas", year: 2002)
      team.names.create!(name: "Quick Step", year: 2003)
      assert_equal(3, team.names.size, "Historical names. #{team.names.map {|n| n.name}.join(', ')}")
      assert_equal("Mapei", team.name(2000), "Historical name 2000")
      assert_equal("Mapei", team.name(2001), "Historical name 2001")
      assert_equal("Mapei-Clas", team.name(2002), "Historical name 2002")
      assert_equal("Quick Step", team.name(2003), "Historical name 2003")
      assert_equal("Quick Step", team.name(2003), "Historical name 2004")
      assert_equal("Vanilla", team.name(Time.zone.today.year - 1), "Last year (after last historical name so should use current name)")
      assert_equal("Vanilla", team.name(Time.zone.today.year), "Name this year")
      assert_equal("Vanilla", team.name(Time.zone.today.year + 1), "Name next year")
    end

    test "rename to old name" do
      team = FactoryGirl.create(:team, name: "Vanilla")
      team.names.create!(name: "Sacha's Team", year: 2001)
      assert_equal(1, team.names.size, "Historical names")
      assert_equal("Sacha's Team", team.name(2001), "Historical name 2001")
      team.name = "Sacha's Team"
      team.save!

      assert_equal("Sacha's Team", team.name, "New name")
    end

    test "rename to other teams name" do
      team_o_safeway = Team.create!(name: "Team Oregon/Safeway")
      team_o_safeway.names.create!(name: "Team Oregon", year: 1.years.ago.year)

      team_o_river_city = Team.create!(name: "Team Oregon/River City")
      event = SingleDayEvent.create!(date: 1.years.ago)
      senior_men = FactoryGirl.create(:category)
      event.races.create!(category: senior_men).results.create!(team: team_o_river_city)
      team_o_river_city.name = "Team Oregon"
      team_o_river_city.save!

      assert_equal("Team Oregon/Safeway", team_o_safeway.name, "Team Oregon/Safeway name")
      assert_equal(1, team_o_safeway.names.size, "Team Oregon/Safeway historical names")
      assert_equal("Team Oregon", team_o_safeway.names.first.name, "Team Oregon/Safeway historical name")

      assert_equal("Team Oregon", team_o_river_city.name, "Team Oregon/River City name")
      assert_equal(1, team_o_river_city.names.size, "Team Oregon/River City historical names")
      assert_equal("Team Oregon/River City", team_o_river_city.names.first.name, "Team Oregon/River City historical name")
    end

    # Reproduce UTF-8 conversion issues
    test "rename to alias" do
      team = Team.create!(name: "Grundelbruisers/Stewie Bicycles")
      team.names.create!(name: "Grundelbruisers/Stewie Bicycles", year: 1.years.ago.year)

      team.reload
      team.name = "Gründelbrüisers/Stewie Bicycles"
      team.save!

      team.reload
      assert_equal("Gründelbrüisers/Stewie Bicycles", team.name, "Team name")
      assert_equal(0, team.aliases.count, "aliases")
      assert_equal(1, team.names.count, "Historical names")
    end

    test "different teams with same name" do
      team_o_safeway = Team.create!(name: "Team Oregon/Safeway")
      team_o_safeway.names.create!(name: "Team Oregon", year: 1.years.ago.year)

      team_o_river_city = Team.create!(name: "Team Oregon/River City")
      team_o_river_city.names.create!(name: "Team Oregon", year: 1.years.ago.year)
    end

    test "renamed teams should keep aliases" do
      team = Team.create!(name: "Twin Peaks/The Bike Nook")
      event = SingleDayEvent.create!(date: 3.years.ago)
      senior_men = FactoryGirl.create(:category)
      event.races.create!(category: senior_men).results.create!(team: team)
      team.aliases.create!(name: "Twin Peaks")
      assert_equal(0, team.names(true).size, "names")
      assert_equal(1, team.aliases(true).size, "Aliases")

      team.name = "Tecate"
      team.save!
      assert_equal(1, team.names(true).size, "names")
      assert_equal(2, team.aliases(true).size, "aliases")
      assert_equal(["Twin Peaks", "Twin Peaks/The Bike Nook"], team.aliases.map(&:name).sort, "Should retain keep alias from old name")
    end

    test "create and override alias" do
      vanilla = FactoryGirl.create(:team, name: "Vanilla")
      vanilla.aliases.create!(name: "Vanilla Bicycles")
      assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla should exist')
      assert_not_nil(Alias.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles alias should exist')
      assert_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles should not exist')

      dupe = Team.create!(name: 'Vanilla Bicycles')
      assert(dupe.valid?, 'Dupe Vanilla should be valid')

      assert_not_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles should exist')
      assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla should exist')
      assert_nil(Alias.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles alias should not exist')
      assert_nil(Alias.find_by_name('Vanilla'), 'Vanilla alias should not exist')
    end

    test "update to alias" do
      vanilla = FactoryGirl.create(:team, name: "Vanilla")
      vanilla.aliases.create!(name: "Vanilla Bicycles")
      assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla should exist')
      assert_not_nil(Alias.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles alias should exist')
      assert_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles should not exist')

      vanilla.name = 'Vanilla Bicycles'
      vanilla.save!
      assert(vanilla.valid?, 'Renamed Vanilla should be valid')

      assert_not_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles should exist')
      assert_nil(Team.find_by_name('Vanilla'), 'Vanilla should not exist')
      assert_nil(Alias.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles alias should not exist')
      assert_not_nil(Alias.find_by_name('Vanilla'), 'Vanilla alias should exist')
    end

    test "update name different case" do
      vanilla = FactoryGirl.create(:team, name: "Vanilla")
      vanilla.aliases.create!(name: "Vanilla Bicycles")
      assert_equal('Vanilla', vanilla.name, 'Name before update')
      vanilla.name = 'vanilla'
      vanilla.save
      assert(vanilla.errors.empty?, 'Should have no errors after save')
      vanilla.reload
      assert_equal('vanilla', vanilla.name, 'Name after update')
    end
  end
end
