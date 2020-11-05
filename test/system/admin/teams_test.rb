# frozen_string_literal: true

require "application_system_test_case"

# :stopdoc:
class TeamsTest < ApplicationSystemTestCase
  test "edit" do
    FactoryBot.create(:team, name: "Kona")
    vanilla = FactoryBot.create(:team, name: "Vanilla")
    vanilla.aliases.create!(name: "Vanilla Bicycles")
    gl = FactoryBot.create(:team, name: "Gentle Lovers")
    gl.aliases.create!(name: "Gentile Lovers")
    FactoryBot.create(:team, name: "Chocolate")
    dfl = FactoryBot.create(:team, name: "Team dFL")
    visit "/teams"

    find("a[href='/teams/#{gl.id}']").click

    login_as FactoryBot.create(:administrator)

    visit "/admin/teams"
    assert_page_has_content "Enter part of a team's name"
    fill_in "name", with: "e\n"

    assert_table("teams_table", 1, 2, "Chocolate")
    assert_table("teams_table", 2, 2, "Gentle Lovers")
    assert_table("teams_table", 3, 2, "Team dFL")
    assert_table("teams_table", 4, 2, "Vanilla")

    assert_table "teams_table", 1, 3, ""
    assert_table("teams_table", 2, 3, "Gentile Lovers")
    assert_table "teams_table", 3, 3, ""
    assert_table("teams_table", 4, 3, "Vanilla Bicycles")

    assert has_checked_field?("team_member_#{dfl.id}")
    assert has_checked_field?("team_member_#{vanilla.id}")
    assert has_checked_field?("team_member_#{gl.id}")
    uncheck "team_member_#{gl.id}"
    wait_for_no :field, "team_member_#{gl.id}", checked: true

    visit "/admin/teams"
    assert !has_checked_field?("team_member_#{gl.id}")

    click_link "show_#{dfl.id}"
    assert_page_has_content "Team dFL"

    visit "/admin/teams"
    click_link "edit_#{vanilla.id}"
    assert_page_has_content "Vanilla"

    fill_in "team_name", with: "SpeedVagen"
    click_button "Save"

    visit "/admin/teams"
    fill_in "name", with: "vagen\n"

    assert_table("teams_table", 1, 2, "SpeedVagen")

    fill_in_inline "#team_#{vanilla.id}_name", with: "Sacha's Team"

    begin
      Timeout.timeout(10) do
        sleep 0.25 until Team.find(vanilla.id).name == "Sacha's Team"
      end
    rescue Timeout::Error
      raise Timeout::Error, "Should update team name after second inline edit"
    end
  end

  test "drag and drop" do
    kona = FactoryBot.create(:team, name: "Kona")
    vanilla = FactoryBot.create(:team, name: "Vanilla")
    FactoryBot.create(:team, name: "Chocolate")
    FactoryBot.create(:team, name: "Team dFL")
    FactoryBot.create(:team, name: "Gentle Lovers")

    login_as FactoryBot.create(:administrator)

    visit "/admin/teams"
    fill_in "name", with: "a\n"

    find("#team_#{kona.id}").drag_to(find("#team_#{vanilla.id}_row"))
    assert_page_has_content "Merged Kona into Vanilla"
    assert !Team.exists?(kona.id), "Kona should be merged"
    assert Team.exists?(vanilla.id), "Vanilla still exists after merge"

    visit "/admin/teams"
    fill_in "name", with: "e\n"

    assert_table("teams_table", 1, 2, "Chocolate")
    assert_table("teams_table", 2, 2, "Gentle Lovers")
    assert_table("teams_table", 3, 2, "Team dFL")
  end

  test "merge confirm" do
    FactoryBot.create(:team, name: "Kona")
    vanilla = FactoryBot.create(:team, name: "Vanilla")
    vanilla.aliases.create!(name: "Vanilla Bicycles")
    FactoryBot.create(:team, name: "Chocolate")
    FactoryBot.create(:team, name: "Team dFL")
    gl = FactoryBot.create(:team, name: "Gentle Lovers")

    login_as FactoryBot.create(:administrator)

    visit "/admin/teams"
    fill_in "name", with: "e\n"

    assert_table("teams_table", 1, 2, "Chocolate")
    assert_table("teams_table", 2, 2, "Gentle Lovers")
    assert_table("teams_table", 3, 2, "Team dFL")
    assert_table("teams_table", 4, 2, "Vanilla")
    assert_table("teams_table", 4, 3, "Vanilla Bicycles")

    fill_in_inline "#team_#{vanilla.id}_name", with: "Gentle Lovers"
    click_button "Merge"

    assert Team.exists?(gl.id), "Should not have merged Gentle Lovers"

    begin
      Timeout.timeout(10) do
        sleep 0.25 while Team.exists?(vanilla.id)
      end
    rescue Timeout::Error
      raise Timeout::Error, "Should have merged Vanilla"
    end

    assert gl.aliases.reload.map(&:name).include?("Vanilla"), "Should add Vanilla alias"
  end
end
