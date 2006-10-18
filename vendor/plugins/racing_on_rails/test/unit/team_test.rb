require File.dirname(__FILE__) + '/../test_helper'

class TeamTest < Test::Unit::TestCase

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
  
  def test_update_to_alias
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla should exist')
    assert_not_nil(Team.find_by_name_or_alias('Vanilla Bicycles'), 'Vanilla Bicycles alias should exist')
    assert_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles should not exist')
    dupe = Team.new(:name => 'Vanilla Bicycles')
    assert(dupe.valid?, 'Dupe Vanilla should be valid')
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
end