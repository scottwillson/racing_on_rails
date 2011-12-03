require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class AliasTest < ActiveSupport::TestCase
  def test_team_alias_with_person_name
    person = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
    Alias.create!(:name => person.name, :team => FactoryGirl.create(:team))
    aliases = Alias.find_all_people_by_name(person.name)
    assert !aliases.include?(nil), "Alias.find_all_people_by_name should not return any nils"
  end
  
  def test_find_all_people_by_name
    person = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
    person_alias = Alias.create!(:name => "Mollie Cameron", :person => person)
    aliases = Alias.find_all_people_by_name("Mollie Cameron")
    assert !aliases.include?(person_alias), "Alias.find_all_people_by_name should find alias"
  end
  
  def test_alias_cannot_shadow_team_name
    team = FactoryGirl.create(:team)
    assert !Alias.create(:name => team.name, :team => team).valid?, "Alias should be invalid"
  end
  
  def test_alias_cannot_shadow_person_name
    person = FactoryGirl.create(:person)
    assert !Alias.create(:name => person.name, :person => person).valid?, "Alias should be invalid"
  end
  
  def test_no_dupe_teams
    alias_record = FactoryGirl.create(:team_alias)
    assert_raise(ActiveRecord::RecordNotUnique, "Alias should be invalid") { Alias.create(:name => alias_record.name, :team => FactoryGirl.create(:team)) }
  end
  
  def test_no_dupe_people
    alias_record = FactoryGirl.create(:person_alias)
    assert_raise(ActiveRecord::RecordNotUnique, "Alias should be invalid") { Alias.create(:name => alias_record.name, :person => FactoryGirl.create(:person)) }
  end
end
