require "acceptance/selenium_test_case"

class TeamsTest < SeleniumTestCase
  def test_teams
    open '/teams'
    assert_no_text 'error'
    assert_no_text 'Unknown action'

    @gl_id = Team.find_by_name("Gentle Lovers").id
    click "css=a[href='/teams/#{@gl_id}']", :wait_for => :page
    assert_no_text 'error'
    assert_no_text 'Unknown action'

    login_as_admin

    open '/admin/teams'
    assert_text "Enter part of a team's name"
    type "name", "e"
    submit_and_wait("search_form")

    assert_element_text "warn", ""
    assert_element_text "notice", ""

    File.open("/Users/sw/Desktop/teams.png", "wb") { |f| f.write Base64.decode64(selenium.capture_entire_page_screenshot_to_string("")) }

    assert_table "teams_table", 1, 0, "glob:Chocolate*"
    assert_table "teams_table", 2, 0, "glob:Gentle Lovers*"
    assert_table "teams_table", 3, 0, "glob:Team dFL*"
    assert_table "teams_table", 4, 0, "glob:Vanilla*"

    assert_table "teams_table", 1, 1, ""
    assert_table "teams_table", 2, 1, "glob:Gentile Lovers*"
    assert_table "teams_table", 3, 1, ""
    assert_table "teams_table", 4, 1, "glob:Vanilla Bicycles*"

    @dfl_id = Team.find_by_name("Team dFL").id
    @vanilla_id = Team.find_by_name("Vanilla").id
    assert_checked "team_member_#{@dfl_id}"
    assert_checked "team_member_#{@vanilla_id}"
    assert_checked "team_member_#{@gl_id}"

    click "team_member_#{@gl_id}"
    wait_for_ajax
    refresh
    wait_for_page
    assert_not_checked "team_member_#{@gl_id}"

    click "css=a[href='/results/team/#{@dfl_id}']", :wait_for => :page
    assert_text "Team dFL"
    assert_no_text 'error'
    assert_no_text 'Unknown action'

    open '/admin/teams'
    click "css=a[href='/admin/teams/#{@vanilla_id}/edit']", :wait_for => :page
    assert_text "Vanilla"
    assert_no_text 'error'
    assert_no_text 'Unknown action'

    type "team_name", "SpeedVagen"
    click "save", :wait_for => :page
    assert_text "SpeedVagen"
    assert_no_text 'error'
    assert_no_text 'Unknown action'
  end
end
