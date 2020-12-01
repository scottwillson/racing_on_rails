# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class AliasTest < ActiveSupport::TestCase
  test "team alias with person name" do
    person = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
    Alias.create!(name: person.name, team: FactoryBot.create(:team))
    aliases = Alias.find_all_people_by_name(person.name).to_a
    assert_not aliases.include?(nil), "Alias.find_all_people_by_name should not return any nils"
  end

  test "find all people by name" do
    person = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
    Alias.create!(name: "Mollie Cameron", person: person)
    Alias.find_all_people_by_name("Ryan Weaver").to_a
    aliases = Alias.find_all_people_by_name("Mollie Cameron").to_a
    assert aliases.include?(person), "Alias.find_all_people_by_name should find alias"
  end

  test "alias cannot shadow team name" do
    team = FactoryBot.create(:team)
    assert_not Alias.create(name: team.name, team: team).valid?, "Alias should be invalid"
  end

  test "alias cannot shadow person name" do
    person = FactoryBot.create(:person)
    assert_not Alias.create(name: person.name, person: person).valid?, "Alias should be invalid"
  end

  test "no dupe teams" do
    alias_record = FactoryBot.create(:team_alias)
    assert_raise(ActiveRecord::RecordNotUnique, "Alias should be invalid") { Alias.create!(name: alias_record.name, team: FactoryBot.create(:team)) }
  end

  test "no dupe people" do
    alias_record = FactoryBot.create(:person_alias)
    assert_raise(ActiveRecord::RecordNotUnique, "Alias should be invalid") { Alias.create!(name: alias_record.name, person: FactoryBot.create(:person)) }
  end
end
