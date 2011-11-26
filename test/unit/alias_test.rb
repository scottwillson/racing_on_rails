require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class AliasTest < ActiveSupport::TestCase
  def test_team_alias_with_person_name
    person = Factory(:person)
    Alias.create :name => person.name, :team => Factory(:team)
    aliases = Alias.find_all_people_by_name(person.name)
    assert !aliases.include?(nil), "Alias.find_all_people_by_name should not return any nils"
  end
  
  def test_alias_cannot_shadow_team_name
    team = Factory(:team)
    assert !Alias.create(:name => team.name, :team => team).valid?, "Alias should be invalid"
  end
  
  def test_alias_cannot_shadow_person_name
    person = Factory(:person)
    assert !Alias.create(:name => person.name, :person => person).valid?, "Alias should be invalid"
  end
  
  def test_no_dupe_teams
    alias_record = Factory(:team_alias)
    assert_raise(ActiveRecord::RecordNotUnique, "Alias should be invalid") { Alias.create(:name => alias_record.name, :team => Factory(:team)) }
  end
  
  def test_no_dupe_people
    alias_record = Factory(:person_alias)
    assert_raise(ActiveRecord::RecordNotUnique, "Alias should be invalid") { Alias.create(:name => alias_record.name, :person => Factory(:person)) }
  end
end
