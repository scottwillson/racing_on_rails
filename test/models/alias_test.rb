require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class AliasTest < ActiveSupport::TestCase
  test "team alias with person name" do
    person = FactoryGirl.create(:person, first_name: "Molly", last_name: "Cameron")
    Alias.create!(name: person.name, team: FactoryGirl.create(:team))
    aliases = Alias.find_all_people_by_name(person.name).to_a
    assert !aliases.include?(nil), "Alias.find_all_people_by_name should not return any nils"
  end

  test "find all people by name" do
    person = FactoryGirl.create(:person, first_name: "Molly", last_name: "Cameron")
    Alias.create!(name: "Mollie Cameron", person: person)
    Alias.find_all_people_by_name("Ryan Weaver").to_a
    aliases = Alias.find_all_people_by_name("Mollie Cameron").to_a
    assert aliases.include?(person), "Alias.find_all_people_by_name should find alias"
  end

  test "alias cannot shadow team name" do
    team = FactoryGirl.create(:team)
    assert !Alias.create(name: team.name, team: team).valid?, "Alias should be invalid"
  end

  test "alias cannot shadow person name" do
    person = FactoryGirl.create(:person)
    assert !Alias.create(name: person.name, person: person).valid?, "Alias should be invalid"
  end

  test "no dupe teams" do
    alias_record = FactoryGirl.create(:team_alias)
    assert_raise(ActiveRecord::RecordNotUnique, "Alias should be invalid") { Alias.create(name: alias_record.name, team: FactoryGirl.create(:team)) }
  end

  test "no dupe people" do
    alias_record = FactoryGirl.create(:person_alias)
    assert_raise(ActiveRecord::RecordNotUnique, "Alias should be invalid") { Alias.create(name: alias_record.name, person: FactoryGirl.create(:person)) }
  end
end
