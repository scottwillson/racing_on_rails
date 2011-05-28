require "acceptance/webdriver_test_case"

# :stopdoc:
class TeamsTest < WebDriverTestCase
  def test_teams
    open '/teams'

    gl_id = Team.find_by_name("Gentle Lovers").id
    click :css => "a[href='/teams/#{gl_id}']"

    login_as :administrator

    open "/admin/teams"
    assert_page_source "Enter part of a team's name"
    type "e", "name"
    submit "search_form"

    assert_text "", "warn"
    assert_text "", "notice"

    assert_table("teams_table", 1, 1, /^Chocolate/)
    assert_table("teams_table", 2, 1, /^Gentle Lovers/)
    assert_table("teams_table", 3, 1, /^Team dFL/)
    assert_table("teams_table", 4, 1, /^Vanilla/)

    assert_table "teams_table", 1, 2, ""
    assert_table("teams_table", 2, 2, /^Gentile Lovers/)
    assert_table "teams_table", 3, 2, ""
    assert_table("teams_table", 4, 2, /^Vanilla Bicycles/)

    dfl_id = Team.find_by_name("Team dFL").id
    vanilla_id = Team.find_by_name("Vanilla").id
    assert_checked "team_member_#{dfl_id}"
    assert_checked "team_member_#{vanilla_id}"
    assert_checked "team_member_#{gl_id}"

    click "team_member_#{gl_id}"
    sleep 1
    refresh
    wait_for_element "teams_table"
    assert_not_checked "team_member_#{gl_id}"

    click :css => "a[href='/teams/#{dfl_id}']"
    assert_page_source "Team dFL"

    open '/admin/teams'
    click "edit_#{vanilla_id}"
    wait_for_element "team_name"
    assert_page_source "Vanilla"

    type "SpeedVagen", "team_name"
    click "save"
    sleep 1
    wait_for_value "SpeedVagen", "team_name"

    open "/admin/teams"
    wait_for_element "name"
    type "vagen", "name"
    submit "search_form"

    assert_table("teams_table", 1, 1, /^SpeedVagen/)
    click "team_#{vanilla_id}_name"
    wait_for_element :css => "form.editor_field input"

    type "SpeedVagen-Vanilla", :css => "form.editor_field input"
    type :return, { :css => "form.editor_field input" }, false
    wait_for_no_element :css => "form.editor_field input"

    click "team_#{vanilla_id}_name"
    wait_for_element :css => "form.editor_field input"

    type "Sacha's Team", :css => "form.editor_field input"
    type :return, { :css => "form.editor_field input" }, false
    wait_for_no_element :css => "form.editor_field input"

    vanilla = Team.find(vanilla_id)
    assert_equal "Sacha's Team", vanilla.name, "Should update team name after second inline edit"
  end
end
