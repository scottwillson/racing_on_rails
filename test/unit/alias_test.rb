require File.dirname(__FILE__) + '/../test_helper'

class AliasTest < Test::Unit::TestCase

  def test_new
    weaver = racers(:weaver)
    assert_nil(Alias.find_by_name('Weaver'), 'Weaver should not exist')
    racer_alias = Alias.new(:racer => weaver, :name => 'Weave Dog')
    racer_alias.save!
    assert_equal(racer_alias, Alias.find_by_name(racer_alias.name), 'alias by name')

    vanilla = teams(:vanilla)
    assert_nil(Alias.find_by_name('Vanilla/S&M'), 'Vanilla Bicycles/S&M should not exist')
    team_alias = Alias.new(:team => vanilla, :name => 'Vanilla Bicycles/S&M')
    team_alias.save!
    assert_equal(team_alias, Alias.find_by_name(team_alias.name), 'alias by name')
  end
  
  def test_team_alias_with_racer_name
    weaver = racers(:weaver)
    Alias.create(:name => weaver.name, :team => teams(:vanilla))
    aliases = Alias.find_all_racers_by_name(weaver.name)
    assert(!aliases.include?(nil), "Alias.find_all_racers_by_name should not return any nils")
  end
  
  def test_alias_cannot_shadow_team_name
    a = Alias.create(:name => teams(:vanilla).name, :team => teams(:vanilla))
    assert(!a.valid?, 'Alias should be invalid')
  end
  
  def test_alias_cannot_shadow_racer_name
    a = Alias.create(:name => racers(:weaver).name, :racer => racers(:weaver))
    assert(!a.valid?, 'Alias should be invalid')
  end
  
  def test_no_dupe_racers
    assert_raise(ActiveRecord::StatementInvalid, 'Alias should be invalid') {Alias.create(:name => 'Gentile Lovers', :team => teams(:vanilla))}
  end
  
  def test_no_dupe_teams
    assert_raise(ActiveRecord::StatementInvalid, 'Alias should be invalid') {Alias.create(:name => 'Mollie Cameron', :racer => racers(:weaver))}
  end
end
