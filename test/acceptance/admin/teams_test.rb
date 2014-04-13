require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class TeamsTest < AcceptanceTest
  setup :javascript!

  def test_edit
    FactoryGirl.create(:team, :name => "Kona")
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    vanilla.aliases.create!(:name => "Vanilla Bicycles")
    gl = FactoryGirl.create(:team, :name => "Gentle Lovers")
    gl.aliases.create!(:name => "Gentile Lovers")
    FactoryGirl.create(:team, :name => "Chocolate")
    dfl = FactoryGirl.create(:team, :name => "Team dFL")
    visit '/teams'

    find("a[href='/teams/#{gl.id}']").click

    login_as FactoryGirl.create(:administrator)

    visit "/admin/teams"
    assert_page_has_content "Enter part of a team's name"
    fill_in "name", :with => "e"
    press_return "name"

    assert_table("teams_table", 2, 2, "Chocolate")
    assert_table("teams_table", 3, 2, "Gentle Lovers")
    assert_table("teams_table", 4, 2, "Team dFL")
    assert_table("teams_table", 5, 2, "Vanilla")

    assert_table "teams_table", 2, 3, ""
    assert_table("teams_table", 3, 3, "Gentile Lovers")
    assert_table "teams_table", 4, 3, ""
    assert_table("teams_table", 5, 3, "Vanilla Bicycles")

    assert has_checked_field?("team_member_#{dfl.id}")
    assert has_checked_field?("team_member_#{vanilla.id}")
    assert has_checked_field?("team_member_#{gl.id}")
    uncheck "team_member_#{gl.id}"
    wait_for_no :field, "team_member_#{gl.id}", { :checked => true }

    visit "/admin/teams"
    assert !has_checked_field?("team_member_#{gl.id}")

    click_link "show_#{dfl.id}"
    assert_page_has_content "Team dFL"

    visit '/admin/teams'
    click_link "edit_#{vanilla.id}"
    assert_page_has_content "Vanilla"

    fill_in "team_name", :with => "SpeedVagen"
    click_button "Save"

    visit "/admin/teams"
    fill_in "name", :with => "vagen"
    press_return "name"

    assert_table("teams_table", 2, 2, "SpeedVagen")

    fill_in_inline "#team_#{vanilla.id}_name", :with => "Sacha's Team"

    begin
      Timeout::timeout(10) do
        until Team.find(vanilla.id).name == "Sacha's Team"
          sleep 0.25
        end
      end
    rescue Timeout::Error
      raise Timeout::Error, "Should update team name after second inline edit"
    end
  end

  def test_drag_and_drop
    kona = FactoryGirl.create(:team, :name => "Kona")
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    FactoryGirl.create(:team, :name => "Chocolate")
    FactoryGirl.create(:team, :name => "Team dFL")
    FactoryGirl.create(:team, :name => "Gentle Lovers")

    login_as FactoryGirl.create(:administrator)

    visit "/admin/teams"
    fill_in "name", :with => "a"
    press_return "name"

    find("#team_#{kona.id}").drag_to(find("#team_#{vanilla.id}_row"))
    assert_page_has_content "Merged Kona into Vanilla"
    assert !Team.exists?(kona.id), "Kona should be merged"
    assert Team.exists?(vanilla.id), "Vanilla still exists after merge"

    visit "/admin/teams"
    fill_in "name", :with => "e"
    press_return "name"

    assert_table("teams_table", 2, 2, "Chocolate")
    assert_table("teams_table", 3, 2, "Gentle Lovers")
    assert_table("teams_table", 4, 2, "Team dFL")
  end

  def test_merge_confirm
    FactoryGirl.create(:team, :name => "Kona")
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    vanilla.aliases.create!(:name => "Vanilla Bicycles")
    FactoryGirl.create(:team, :name => "Chocolate")
    FactoryGirl.create(:team, :name => "Team dFL")
    gl = FactoryGirl.create(:team, :name => "Gentle Lovers")

    login_as FactoryGirl.create(:administrator)

    visit "/admin/teams"
    fill_in "name", :with => "e"
    press_return "name"

    assert_table("teams_table", 2, 2, "Chocolate")
    assert_table("teams_table", 3, 2, "Gentle Lovers")
    assert_table("teams_table", 4, 2, "Team dFL")
    assert_table("teams_table", 5, 2, "Vanilla")
    assert_table("teams_table", 5, 3, "Vanilla Bicycles")

    fill_in_inline "#team_#{vanilla.id}_name", :with => "Gentle Lovers"
    click_button "Merge"

    assert Team.exists?(gl.id), "Should not have merged Gentle Lovers"

    begin
      Timeout::timeout(10) do
        while Team.exists?(vanilla.id)
          sleep 0.25
        end
      end
    rescue Timeout::Error
      raise Timeout::Error, "Should have merged Vanilla"
    end

    assert gl.aliases(true).map(&:name).include?("Vanilla"), "Should add Vanilla alias"
  end
end
