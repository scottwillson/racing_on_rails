require "acceptance/webdriver_test_case"

class TeamsTest < WebDriverTestCase
  def test_teams
    open '/teams'

    @gl_id = Team.find_by_name("Gentle Lovers").id
    click :css => "a[href='/teams/#{@gl_id}']"

    login_as :administrator 

    open '/admin/teams'
    assert_page_source "Enter part of a team's name"
    type "e", "name"
    submit "search_form"

    assert_text "", "warn"
    assert_text "", "notice"

    assert_table("teams_table", 1, 0, /^Chocolate/)
    assert_table("teams_table", 2, 0, /^Gentle Lovers/)
    assert_table("teams_table", 3, 0, /^Team dFL/)
    assert_table("teams_table", 4, 0, /^Vanilla/)

    assert_table "teams_table", 1, 1, ""
    assert_table("teams_table", 2, 1, /^Gentile Lovers/)
    assert_table "teams_table", 3, 1, ""
    assert_table("teams_table", 4, 1, /^Vanilla Bicycles/)

    @dfl_id = Team.find_by_name("Team dFL").id
    @vanilla_id = Team.find_by_name("Vanilla").id
    assert_checked "team_member_#{@dfl_id}"
    assert_checked "team_member_#{@vanilla_id}"
    assert_checked "team_member_#{@gl_id}"

    click "team_member_#{@gl_id}"
    sleep 1
    refresh
    wait_for_element "teams_table"
    assert_not_checked "team_member_#{@gl_id}"

    click :css => "a[href='/results/team/#{@dfl_id}']"
    assert_page_source "Team dFL"

    open '/admin/teams'
    click :css => "a[href='/admin/teams/#{@vanilla_id}/edit']"
    assert_page_source "Vanilla"

    type "SpeedVagen", "team_name"
    click "save"
    sleep 1
    wait_for_value "SpeedVagen", "team_name"
  end
end
