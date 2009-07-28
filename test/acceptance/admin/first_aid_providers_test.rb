require "acceptance/selenium_test_case"

class FirstAidProvidersTest < SeleniumTestCase
  def test_first_aid_providers
    login_as_admin

    open "/admin/first_aid_providers"
    FileUtils.mkdir_p "tmp/test/1"
    File.open("tmp/test/1/1-open.png", "wb") { |f| f.write Base64.decode64(capture_entire_page_screenshot_to_string("")) }

    assert_table "events_table", 1, 0, "glob:-------------*"
    assert_table "events_table", 1, 2, "glob:Lost Series*"
    assert_table "events_table", 1, 3, "glob:Brad Ross*"
    assert_table "events_table", 2, 2, "glob:National Federation Event*"
    assert_table "events_table", 2, 0, "glob:-------------*"

    assert_present "xpath=//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='in_place_editable']"
    click "xpath=//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='in_place_editable']"
    wait_for :element => "css=.editor_field"
    File.open("tmp/test/1/2-edit.png", "wb") { |f| f.write Base64.decode64(capture_entire_page_screenshot_to_string("")) }
    type "css=.editor_field", "Megan Weaver"
    submit "css=.inplaceeditor-form"
    wait_for_ajax
    wait_for :element => "css=.editor_field"
    File.open("tmp/test/1/3-edited.png", "wb") { |f| f.write Base64.decode64(capture_entire_page_screenshot_to_string("")) }

    refresh
    wait_for_page
    File.open("tmp/test/1/4-refresh.png", "wb") { |f| f.write Base64.decode64(capture_entire_page_screenshot_to_string("")) }
    assert_table "events_table", 1, 0, "glob:Megan Weaver*"

    click "past_events"
    wait_for_page
    assert_table "events_table", 1, 2, "glob:Copperopolis*"

    click "past_events"
    wait_for_page
    assert_no_text "Copperopolis"

    assert_table "events_table", 1, 2, "glob:Lost Series*"
    assert_table "events_table", 2, 2, "glob:National Federation Event*"

    # Table already sorted by date ascending, so click doesn't change order
    File.open("tmp/test/1/5-before_date_sort.png", "wb") { |f| f.write Base64.decode64(capture_entire_page_screenshot_to_string("")) }
    click "css=th.date a"
    wait_for_page
    File.open("tmp/test/1/6-after_date_sort.png", "wb") { |f| f.write Base64.decode64(capture_entire_page_screenshot_to_string("")) }
    assert_table "events_table", 1, 2, "glob:Lost Series*"
    assert_table "events_table", 2, 2, "glob:National Federation Event*"

    click "css=th.date a"
    wait_for_page
    assert_table "events_table", 1, 2, "glob:National Federation Event*"
    assert_table "events_table", 2, 2, "glob:Lost Series*"

    click "css=th.date a"
    wait_for_page
    assert_table "events_table", 1, 2, "glob:Lost Series*"
    assert_table "events_table", 2, 2, "glob:National Federation Event*"    
  end
end
