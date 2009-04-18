require "test_helper"

class TeamTest < ActiveSupport::TestCase
  def test_find_by_name_or_alias_or_create
    assert_equal(teams(:gentle_lovers), Team.find_by_name_or_alias_or_create('Gentle Lovers'), 'Gentle Lovers')
    assert_equal(teams(:gentle_lovers), Team.find_by_name_or_alias_or_create('Gentile Lovers'), 'Gentle Lovers alias')
    assert_nil(Team.find_by_name_or_alias('Health Net'), 'Health Net should not exist')
    team = Team.find_by_name_or_alias_or_create('Health Net')
    assert_not_nil(team, 'Health Net')
    assert_equal('Health Net', team.name, 'New team')
  end
  
  def test_merge
    team_to_keep = teams(:vanilla)
    team_to_merge = teams(:gentle_lovers)
    
    assert_not_nil(Team.find_by_name(team_to_keep.name), "#{team_to_keep.name} should be in DB")
    assert_equal(2, Result.find_all_by_team_id(team_to_keep.id).size, "Vanilla's results")
    assert_equal(1, Racer.find_all_by_team_id(team_to_keep.id).size, "Vanilla's racers")
    assert_equal(1, Alias.find_all_by_team_id(team_to_keep.id).size, "Vanilla's aliases")
    
    assert_not_nil(Team.find_by_name(team_to_merge.name), "#{team_to_merge.name} should be in DB")
    assert_equal(1, Result.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's results")
    assert_equal(2, Racer.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's racers")
    assert_equal(1, Alias.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's aliases")
    
    team_to_keep.merge(team_to_merge)
    
    assert_not_nil(Team.find_by_name(team_to_keep.name), "#{team_to_keep.name} should be in DB")
    assert_equal(3, Result.find_all_by_team_id(team_to_keep.id).size, "Vanilla's results")
    assert_equal(3, Racer.find_all_by_team_id(team_to_keep.id).size, "Vanilla's racers")
    aliases = Alias.find_all_by_team_id(team_to_keep.id)
    lovers_alias = aliases.detect{|a| a.name == 'Gentle Lovers'}
    assert_not_nil(lovers_alias, 'Vanilla should have Gentle Lovers alias')
    assert_equal(3, aliases.size, "Vanilla's aliases")
    
    assert_nil(Team.find_by_name(team_to_merge.name), "#{team_to_merge.name} should not be in DB")
    assert_equal(0, Result.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's results")
    assert_equal(0, Racer.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's racers")
    assert_equal(0, Alias.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's aliases")
  end
    
  def test_find_by_name_or_alias
    # new
    name = 'Brooklyn Cycling Force'
    assert_nil(Team.find_by_name(name), "#{name} should not exist")
    team = Team.find_by_name_or_alias(name)
    assert_nil(Team.find_by_name(name), "#{name} should not exist")
    assert_nil(team, "#{name} should not exist")
    
    # exists
    Team.create(:name => name)
    team = Team.find_by_name_or_alias(name)
    assert_not_nil(team, "#{name} should exist")
    assert_equal(name, team.name, 'name')

    # alias
    Alias.create(:name => 'BCF', :team => team)
    team = Team.find_by_name_or_alias('BCF')
    assert_not_nil(team, "#{name} should exist")
    assert_equal(name, team.name, 'name')
    
    team = Team.find_by_name_or_alias(name)
    assert_not_nil(team, "#{name} should exist")
    assert_equal(name, team.name, 'name')
  end
  
  def test_create_dupe
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla should exist')
    dupe = Team.new(:name => 'Vanilla')
    assert(!dupe.valid?, 'Dupe Vanilla should not be valid')
  end
  
  def test_create_and_override_alias
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla should exist')
    assert_not_nil(Alias.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles alias should exist')
    assert_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles should not exist')

    dupe = Team.create!(:name => 'Vanilla Bicycles')
    assert(dupe.valid?, 'Dupe Vanilla should be valid')
    
    assert_not_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles should exist')
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla should exist')
    assert_nil(Alias.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles alias should not exist')
    assert_nil(Alias.find_by_name('Vanilla'), 'Vanilla alias should not exist')
  end
  
  def test_update_to_alias
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla should exist')
    assert_not_nil(Alias.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles alias should exist')
    assert_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles should not exist')

    vanilla = teams(:vanilla)
    vanilla.name = 'Vanilla Bicycles'
    vanilla.save!
    assert(vanilla.valid?, 'Renamed Vanilla should be valid')
    
    assert_not_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles should exist')
    assert_nil(Team.find_by_name('Vanilla'), 'Vanilla should not exist')
    assert_nil(Alias.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles alias should not exist')
    assert_not_nil(Alias.find_by_name('Vanilla'), 'Vanilla alias should exist')
  end
  
  def test_update_name_different_case
    vanilla = teams(:vanilla)
    assert_equal('Vanilla', vanilla.name, 'Name before update')
    vanilla.name = 'vanilla'
    vanilla.save
    assert(vanilla.errors.empty?, 'Should have no errors after save')
    vanilla.reload
    assert_equal('vanilla', vanilla.name, 'Name after update')
  end

  def test_member
    team = Team.new(:name => 'Team Spine')
    assert_equal(false, team.member, 'member')
    team.save!
    team.reload
    assert_equal(false, team.member, 'member')

    team = Team.new(:name => 'California Road Club')
    assert_equal(false, team.member, 'member')
    team.member = true
    assert_equal(true, team.member, 'member')
    team.save!
    team.reload
    assert_equal(true, team.member, 'member')

    team.member = true
    team.save!
    team.reload
    assert_equal(true, team.member, 'member')
  end
  
  def test_name_with_date
    team = Team.create!(:name => "Tecate-Una Mas")
    assert_equal(0, team.historical_names(true).size, "historical_names")
    
    team.historical_names.create!(:name => "Team Tecate", :date => 1.years.ago)
    assert_equal(1, team.historical_names(true).size, "historical_names")
    
    team.historical_names.create!(:name => "Twin Peaks", :date => 2.years.ago)
    assert_equal(2, team.historical_names(true).size, "historical_names")
    
    assert_equal("Tecate-Una Mas", team.name)
    assert_equal("Tecate-Una Mas", team.name(Date.today))
    assert_equal("Team Tecate", team.name(1.years.ago))
    assert_equal("Twin Peaks", team.name(2.years.ago))
    assert_equal("Tecate-Una Mas", team.name(Date.today.next_year))
  end
  
  def test_create_new_name_if_there_are_results_from_previous_year
    team = Team.create!(:name => "Twin Peaks")
    event = SingleDayEvent.create!(:date => 1.years.ago)
    old_result = event.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    assert_equal("Twin Peaks", old_result.team_name, "Team name on old result")
    
    event = SingleDayEvent.create!(:date => Date.today)
    result = event.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    assert_equal("Twin Peaks", result.team_name, "Team name on new result")
    assert_equal("Twin Peaks", old_result.team_name, "Team name on old result")
    
    team.name = "Tecate-Una Mas"
    team.save!

    assert_equal(1, team.historical_names(true).size, "historical_names")

    assert_equal("Twin Peaks", old_result.team_name, "Team name should stay the same on old result")
    assert_equal("Tecate-Una Mas", result.team_name, "Team name should change on this year's result")
  end
  
  def test_results_before_this_year
    team = Team.create!(:name => "Twin Peaks")
    assert(!team.results_before_this_year?, "results_before_this_year? with no results")
    
    event = SingleDayEvent.create!(:date => Date.today)
    result = event.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    assert(!team.results_before_this_year?, "results_before_this_year? with results in this year")
    
    result.destroy
    
    event = SingleDayEvent.create!(:date => 1.years.ago)
    event.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    team.results_before_this_year?
    assert(team.results_before_this_year?, "results_before_this_year? with results only a year ago")
    
    event = SingleDayEvent.create!(:date => 2.years.ago)
    event.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    team.results_before_this_year?
    assert(team.results_before_this_year?, "results_before_this_year? with several old results")

    event = SingleDayEvent.create!(:date => Date.today)
    event.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    team.results_before_this_year?
    assert(team.results_before_this_year?, "results_before_this_year? with results in many years")
  end
  
  def test_rename_multiple_times
    team = Team.create!(:name => "Twin Peaks")    
    event = SingleDayEvent.create!(:date => 3.years.ago)
    result = event.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    assert_equal(0, team.historical_names(true).size, "historical_names")
    
    team.name = "Tecate"
    team.save!
    assert_equal(1, team.historical_names(true).size, "historical_names")
    assert_equal(1, team.aliases(true).size, "aliases")
    
    team.name = "Tecate Una Mas"
    team.save!
    assert_equal(1, team.historical_names(true).size, "historical_names")
    assert_equal(2, team.aliases(true).size, "aliases")
    
    team.name = "Tecate-¡Una Mas!"
    team.save!
    assert_equal(1, team.historical_names(true).size, "historical_names")
    assert_equal(3, team.aliases(true).size, "aliases")
    
    assert_equal("Tecate-¡Una Mas!", team.name, "New team name")
    assert_equal("Twin Peaks", team.historical_names.first.name, "Old team name")
    assert_equal(Date.today.year - 1, team.historical_names.first.year, "Old team name year")
  end

  def test_historical_name_date_or_year
    team = teams(:vanilla)
    HistoricalName.create!(:team_id => team.id, :name => "Sacha's Team", :year => 2001)
    assert_equal("Sacha's Team", team.name(Date.new(2001, 12, 31)), "name for 2001-12-31")
    assert_equal("Sacha's Team", team.name(Date.new(2001)), "name for 2001-01-01")
    assert_equal("Sacha's Team", team.name(2001), "name for 2001")
  end

  def test_multiple_historical_names
    team = teams(:vanilla)
    HistoricalName.create!(:team_id => team.id, :name => "Mapei", :year => 2001)
    HistoricalName.create!(:team_id => team.id, :name => "Mapei-Clas", :year => 2002)
    HistoricalName.create!(:team_id => team.id, :name => "Quick Step", :year => 2003)
    assert_equal(3, team.historical_names.size, "Historical names. #{team.historical_names.map {|n| n.name}.join(', ')}")
    assert_equal("Mapei", team.name(2000), "Historical name 2000")
    assert_equal("Mapei", team.name(2001), "Historical name 2001")
    assert_equal("Mapei-Clas", team.name(2002), "Historical name 2002")
    assert_equal("Quick Step", team.name(2003), "Historical name 2003")
    assert_equal("Quick Step", team.name(2003), "Historical name 2004")
    assert_equal("Quick Step", team.name(Date.today.year - 1), "Historical name last year")
    assert_equal("Vanilla", team.name(Date.today.year), "Name this year")
    assert_equal("Vanilla", team.name(Date.today.year + 1), "Name next year")
  end
 
  def test_rename_to_old_name
    team = teams(:vanilla)
    HistoricalName.create!(:team_id => team.id, :name => "Sacha's Team", :year => 2001)
    assert_equal(1, team.historical_names.size, "Historical names")
    assert_equal("Sacha's Team", team.name(2001), "Historical name 2001")
    team.name = "Sacha's Team"
    team.save!
    
    assert_equal("Sacha's Team", team.name, "New name")
  end
  
  def test_rename_to_other_teams_historical_name
    team_o_safeway = Team.create!(:name => "Team Oregon/Safeway")
    team_o_safeway.historical_names.create!(:name => "Team Oregon", :year => 1.years.ago.year)
    
    team_o_river_city = Team.create!(:name => "Team Oregon/River City")
    event = SingleDayEvent.create!(:date => 1.years.ago)
    result = event.races.create!(:category => categories(:senior_men)).results.create!(:team => team_o_river_city)
    team_o_river_city.name = "Team Oregon"
    team_o_river_city.save!
    
    assert_equal("Team Oregon/Safeway", team_o_safeway.name, "Team Oregon/Safeway name")
    assert_equal(1, team_o_safeway.historical_names.size, "Team Oregon/Safeway historical names")
    assert_equal("Team Oregon", team_o_safeway.historical_names.first.name, "Team Oregon/Safeway historical name")
    
    assert_equal("Team Oregon", team_o_river_city.name, "Team Oregon/River City name")
    assert_equal(1, team_o_river_city.historical_names.size, "Team Oregon/River City historical names")
    assert_equal("Team Oregon/River City", team_o_river_city.historical_names.first.name, "Team Oregon/River City historical name")
  end
  
  def test_different_teams_with_same_historical_name
    team_o_safeway = Team.create!(:name => "Team Oregon/Safeway")
    team_o_safeway.historical_names.create!(:name => "Team Oregon", :year => 1.years.ago.year)

    team_o_river_city = Team.create!(:name => "Team Oregon/River City")
    team_o_river_city.historical_names.create!(:name => "Team Oregon", :year => 1.years.ago.year)
  end
  
  def test_renamed_teams_should_keep_aliases
    team = Team.create!(:name => "Twin Peaks/The Bike Nook")
    event = SingleDayEvent.create!(:date => 3.years.ago)
    result = event.races.create!(:category => categories(:senior_men)).results.create!(:team => team)
    team.aliases.create!(:name => "Twin Peaks")
    assert_equal(0, team.historical_names(true).size, "historical_names")
    assert_equal(1, team.aliases(true).size, "Aliases")
    
    team.name = "Tecate"
    team.save!
    assert_equal(1, team.historical_names(true).size, "historical_names")
    assert_equal(2, team.aliases(true).size, "aliases")
    assert_equal(["Twin Peaks", "Twin Peaks/The Bike Nook"], team.aliases.map(&:name).sort, "Should retain keep alias from old name")
  end
end