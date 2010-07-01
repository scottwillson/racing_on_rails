require File.expand_path("../../test_helper", __FILE__)

class AliasTest < ActiveSupport::TestCase

  def test_new
    weaver = people(:weaver)
    assert_nil(Alias.find_by_name('Weaver'), 'Weaver should not exist')
    person_alias = Alias.new(:person => weaver, :name => 'Weave Dog')
    person_alias.save!
    assert_equal(person_alias, Alias.find_by_name(person_alias.name), 'alias by name')

    vanilla = teams(:vanilla)
    assert_nil(Alias.find_by_name('Vanilla/S&M'), 'Vanilla Bicycles/S&M should not exist')
    team_alias = Alias.new(:team => vanilla, :name => 'Vanilla Bicycles/S&M')
    team_alias.save!
    assert_equal(team_alias, Alias.find_by_name(team_alias.name), 'alias by name')
  end
  
  def test_team_alias_with_person_name
    weaver = people(:weaver)
    Alias.create(:name => weaver.name, :team => teams(:vanilla))
    aliases = Alias.find_all_people_by_name(weaver.name)
    assert(!aliases.include?(nil), "Alias.find_all_people_by_name should not return any nils")
  end
  
  def test_alias_cannot_shadow_team_name
    a = Alias.create(:name => teams(:vanilla).name, :team => teams(:vanilla))
    assert(!a.valid?, 'Alias should be invalid')
  end
  
  def test_alias_cannot_shadow_person_name
    a = Alias.create(:name => people(:weaver).name, :person => people(:weaver))
    assert(!a.valid?, 'Alias should be invalid')
  end
  
  def test_no_dupe_people
    assert_raise(ActiveRecord::StatementInvalid, 'Alias should be invalid') {Alias.create(:name => 'Gentile Lovers', :team => teams(:vanilla))}
  end
  
  def test_no_dupe_teams
    assert_raise(ActiveRecord::StatementInvalid, 'Alias should be invalid') {Alias.create(:name => 'Mollie Cameron', :person => people(:weaver))}
  end
end
