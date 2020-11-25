# frozen_string_literal: true

require File.expand_path("../../../test_helper", __FILE__)

module Teams
  # :stopdoc:
  class TeamTest < ActiveSupport::TestCase
    test "find by name or alias or create" do
      # Add person alias with team name to expose bug
      person = FactoryBot.create(:person)
      person.aliases.create!(name: "Gentile Lovers")
      person.aliases.create!(name: "Gentle Lovers")

      gentle_lovers = FactoryBot.create(:team, name: "Gentle Lovers")
      gentle_lovers.aliases.create!(name: "Gentile Lovers")
      assert_equal(gentle_lovers, Team.find_by_name_or_alias_or_create("Gentle Lovers"), "Gentle Lovers")
      assert_equal(gentle_lovers, Team.find_by_name_or_alias_or_create("Gentile Lovers"), "Gentle Lovers alias")
      assert_nil(Team.find_by_name_or_alias("Health Net"), "Health Net should not exist")
      team = Team.find_by_name_or_alias_or_create("Health Net")
      assert_not_nil(team, "Health Net")
      assert_equal("Health Net", team.name, "New team")
    end

    test "find by name or alias" do
      # new
      name = "Brooklyn Cycling Force"
      assert_nil(Team.find_by(name: name), "#{name} should not exist")
      team = Team.find_by_name_or_alias(name)
      assert_nil(Team.find_by(name: name), "#{name} should not exist")
      assert_nil(team, "#{name} should not exist")

      # exists
      Team.create(name: name)
      team = Team.find_by_name_or_alias(name)
      assert_not_nil(team, "#{name} should exist")
      assert_equal(name, team.name, "name")

      # alias
      Alias.create(name: "BCF", team: team)
      team = Team.find_by_name_or_alias("BCF")
      assert_not_nil(team, "#{name} should exist")
      assert_equal(name, team.name, "name")

      team = Team.find_by_name_or_alias(name)
      assert_not_nil(team, "#{name} should exist")
      assert_equal(name, team.name, "name")
    end

    test "find all by name like" do
      vanilla = FactoryBot.create(:team, name: "Vanilla")
      vanilla.aliases.create!(name: "Vanilla Bicycles")
      assert_same_elements [vanilla], Team.name_like("Vanilla"), "Vanilla"
      assert_same_elements [vanilla], Team.name_like("Vanilla Bicycles"), "Vanilla Bicycles"
      assert_same_elements [vanilla], Team.name_like("van"), "van"
      assert_same_elements [vanilla], Team.name_like("cyc"), "cyc"

      steelman = Team.create!(name: "Steelman Cycles")
      assert_same_elements [steelman, vanilla], Team.name_like("cycles"), "cycles"
    end

    test "create dupe" do
      FactoryBot.create(:team, name: "Vanilla")
      dupe = Team.new(name: "Vanilla")
      assert_not dupe.valid?, "Dupe Vanilla should not be valid"
    end

    test "member" do
      team = Team.new(name: "Team Spine")
      assert_equal(false, team.member, "member")
      team.save!
      team.reload
      assert_equal(false, team.member, "member")

      team = Team.new(name: "California Road Club")
      assert_equal(false, team.member, "member")
      team.member = true
      assert_equal(true, team.member, "member")
      team.save!
      team.reload
      assert_equal(true, team.member, "member")

      team.member = true
      team.save!
      team.reload
      assert_equal(true, team.member, "member")
    end

    test "delete updated by" do
      team = FactoryBot.create(:team)
      person = FactoryBot.create(:person, name: "Admin")
      team.updater = person
      team.name = "7-11"
      team.save!
      assert_equal "Admin", team.updated_by_name, "updated_by_name"

      person.destroy
      assert !Person.exists?(person.id), "Updater Person should be destroyed"

      assert_equal "Admin", team.updated_by_name, "updated_by_name"
    end
  end
end
