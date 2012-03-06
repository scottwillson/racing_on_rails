# coding: utf-8

require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class TeamTest < ActiveSupport::TestCase
  def test_find_by_name_or_alias_or_create
    gentle_lovers = FactoryGirl.create(:team, :name => "Gentle Lovers")
    gentle_lovers.aliases.create!(:name => "Gentile Lovers")
    assert_equal(gentle_lovers, Team.find_by_name_or_alias_or_create('Gentle Lovers'), 'Gentle Lovers')
    assert_equal(gentle_lovers, Team.find_by_name_or_alias_or_create('Gentile Lovers'), 'Gentle Lovers alias')
    assert_nil(Team.find_by_name_or_alias('Health Net'), 'Health Net should not exist')
    team = Team.find_by_name_or_alias_or_create('Health Net')
    assert_not_nil(team, 'Health Net')
    assert_equal('Health Net', team.name, 'New team')
  end
  
  def test_merge
    team_to_keep = FactoryGirl.create(:team, :name => "Vanilla")
    team_to_keep.aliases.create!(:name => "Vanilla Bicycles")
    FactoryGirl.create(:result, :team => team_to_keep)
    FactoryGirl.create(:result, :team => team_to_keep)
    FactoryGirl.create(:person, :team => team_to_keep)

    team_to_merge = FactoryGirl.create(:team, :name => "Gentle Lovers")
    team_to_merge.aliases.create!(:name => "Gentile Lovers")
    FactoryGirl.create(:result, :team => team_to_merge)
    FactoryGirl.create(:person, :team => team_to_merge)
    FactoryGirl.create(:person, :team => team_to_merge)
    FactoryGirl.create(:person, :team => team_to_merge)
    
    assert_not_nil(Team.find_by_name(team_to_keep.name), "#{team_to_keep.name} should be in DB")
    assert_equal(2, Result.find_all_by_team_id(team_to_keep.id).size, "Vanilla's results")
    assert_equal(1, Person.find_all_by_team_id(team_to_keep.id).size, "Vanilla's people")
    assert_equal(1, Alias.find_all_by_team_id(team_to_keep.id).size, "Vanilla's aliases")
    
    assert_not_nil(Team.find_by_name(team_to_merge.name), "#{team_to_merge.name} should be in DB")
    assert_equal(1, Result.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's results")
    assert_equal(3, Person.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's people")
    assert_equal(1, Alias.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's aliases")
    
    promoter_events = [ Event.create!(:team => team_to_keep), Event.create!(:team => team_to_merge) ]

    team_to_keep.merge(team_to_merge)
    
    assert_not_nil(Team.find_by_name(team_to_keep.name), "#{team_to_keep.name} should be in DB")
    assert_equal(3, Result.find_all_by_team_id(team_to_keep.id).size, "Vanilla's results")
    assert_equal(4, Person.find_all_by_team_id(team_to_keep.id).size, "Vanilla's people")
    aliases = Alias.find_all_by_team_id(team_to_keep.id)
    lovers_alias = aliases.detect{|a| a.name == 'Gentle Lovers'}
    assert_not_nil(lovers_alias, 'Vanilla should have Gentle Lovers alias')
    assert_equal(3, aliases.size, "Vanilla's aliases")
    
    assert_nil(Team.find_by_name(team_to_merge.name), "#{team_to_merge.name} should not be in DB")
    assert_equal(0, Result.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's results")
    assert_equal(0, Person.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's people")
    assert_equal(0, Alias.find_all_by_team_id(team_to_merge.id).size, "Gentle Lovers's aliases")
    assert_same_elements(promoter_events, team_to_keep.events(true), "Should merge sponsored events")
  end
  
  def test_merge_with_names
    current_year = Time.zone.today.year
    last_year = current_year - 1

    team_to_keep = Team.create!(:name => "Team Oregon/River City Bicycles")
    team_to_keep_last_year = team_to_keep.names.create!(:name => "Team Oregon/River City Bicycles", :year => last_year)
    
    event = SingleDayEvent.create!
    senior_men = FactoryGirl.create(:category)
    event.races.create!(:category => senior_men).results.create!(:place => "10", :team => team_to_keep)

    event = SingleDayEvent.create!(:date => Date.new(last_year))
    event.races.create!(:category => senior_men).results.create!(:place => "2", :team => team_to_keep)
    
    team_to_merge = Team.create!(:name => "Team O/RCB")
    team_to_merge.names.create!(:name => "Team o IRCB", :year => last_year)
    
    event = SingleDayEvent.create!
    event.races.create!(:category => senior_men).results.create!(:place => "4", :team => team_to_merge)

    event = SingleDayEvent.create!(:date => Date.new(last_year))
    team_to_merge_last_year_result = event.races.create!(:category => senior_men).results.create!(:place => "19", :team => team_to_merge)

    team_to_keep.merge(team_to_merge)
    
    assert(!Team.exists?(team_to_merge.id), "Should delete merged team")
    assert_equal(1, team_to_keep.names.count, "Target team historical names")
    assert_equal(team_to_keep_last_year, team_to_keep.names.first, "Target team historical name")
    
    # If the merged team has historical names, those need to become teams with results from those years
    team_to_merge_last_year = Team.find_by_name("Team o IRCB")
    assert_not_nil(team_to_merge_last_year, "Merged team's historical name should become a new team")
    assert_equal(1, team_to_merge_last_year.results.count, "Merged team's historical name results")
    assert_equal(team_to_merge_last_year_result, team_to_merge_last_year.results.first, "Merged team's historical name results")
    assert_equal(0, team_to_merge_last_year.names.count, "Merged team's historical name historical names")
    
    assert_equal(3, team_to_keep.results.count, "Target team's results")
    assert_equal(1, team_to_keep.names.count, "Target team's historical names")
    assert_equal(1, team_to_keep.aliases.count, "Target team's aliases")
  end
    
  def test_merge_with_names_that_match_existing_team
    current_year = Time.zone.today.year
    last_year = current_year - 1

    team_to_keep = Team.create!(:name => "Team Oregon/River City Bicycles")
    team_to_keep_last_year = team_to_keep.names.create!(:name => "Team Oregon/River City Bicycles", :year => last_year)
        
    team_to_merge = Team.create!(:name => "Team O/RCB")
    team_to_merge.names.create!(:name => "Team o IRCB", :year => last_year)
    
    Team.create!(:name => "Team o IRCB")
    
    team_to_keep.merge(team_to_merge)
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
  
  def test_find_all_by_name_like
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    vanilla.aliases.create!(:name => "Vanilla Bicycles")
    assert_same_elements [vanilla], Team.find_all_by_name_like("Vanilla"), "Vanilla"
    assert_same_elements [vanilla], Team.find_all_by_name_like("Vanilla Bicycles"), "Vanilla Bicycles"
    assert_same_elements [vanilla], Team.find_all_by_name_like("van"), "van"
    assert_same_elements [vanilla], Team.find_all_by_name_like("cyc"), "cyc"
    
    steelman = Team.create!(:name => "Steelman Cycles")
    assert_same_elements [steelman, vanilla], Team.find_all_by_name_like("cycles"), "cycles"
  end
  
  def test_create_dupe
    FactoryGirl.create(:team, :name => "Vanilla")
    dupe = Team.new(:name => 'Vanilla')
    assert(!dupe.valid?, 'Dupe Vanilla should not be valid')
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

  def test_delete_updater
    team = FactoryGirl.create(:team)
    person = FactoryGirl.create(:person)
    team.updater = person
    team.name = "7-11"
    team.save!
    assert_equal person, team.versions.last.user, " version user"
    assert_equal person, team.updated_by, "updated_by"

    person.destroy
    assert !Person.exists?(person.id), "Updater Person should be destroyed"

    assert_equal nil, team.versions(true).last.user, " version user"
    assert_equal nil, team.updated_by, "updated_by"
  end
end
