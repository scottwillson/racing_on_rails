require "acceptance/selenium_test_case"

class FirstAidProvidersTest < SeleniumTestCase
  def test_first_aid_providers
    # FIXME Punt!
    if Date.today.month < 12
      login_as :administrator

      open "/admin/first_aid_providers"

      assert_table "events_table", 1, 3, "glob:Lost Series*"
      assert_table "events_table", 1, 4, "glob:Brad Ross*"
      assert_table "events_table", 2, 3, "glob:National Federation Event*"

      assert_present "xpath=//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='in_place_editable']"
      click "xpath=//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='in_place_editable']", :wait_for => { :element => "css=.editor_field" }
      type "css=.editor_field", "Megan Weaver"
      submit "css=.inplaceeditor-form"
      wait_for_ajax
      wait_for :element => "css=.editor_field"

      refresh
      wait_for_page
      assert_table "events_table", 1, 0, "glob:Megan Weaver*"

      click "past_events", :wait_for => :page
      assert_table "events_table", 1, 3, "glob:Copperopolis*"

      click "past_events", :wait_for => :page
      assert_no_text "Copperopolis"

      assert_table "events_table", 1, 3, "glob:Lost Series*"
      assert_table "events_table", 2, 3, "glob:National Federation Event*"

      # Table already sorted by date ascending, so click doesn't change order
      click "css=th.date a", :wait_for => :page
      assert_table "events_table", 1, 3, "glob:Lost Series*"
      assert_table "events_table", 2, 3, "glob:National Federation Event*"

      click "css=th.date a", :wait_for => :page
      assert_table "events_table", 1, 3, "glob:National Federation Event*"
      assert_table "events_table", 2, 3, "glob:Lost Series*"

      click "css=th.date a", :wait_for => :page
      assert_table "events_table", 1, 3, "glob:Lost Series*"
      assert_table "events_table", 2, 3, "glob:National Federation Event*"    
    end  
  end
end
