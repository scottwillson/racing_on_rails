require "acceptance/webdriver_test_case"

class FirstAidProvidersTest < WebDriverTestCase
  def test_first_aid_providers
    # FIXME Punt!
    if Date.today.month < 12
      login_as :administrator

      open "/admin/first_aid_providers"

      assert_table "events_table", 1, 3, /^Lost Series/
      assert_table "events_table", 1, 4, /^Brad Ross/
      assert_table "events_table", 2, 3, /^National Federation Event/

      assert_element :xpath => "//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='in_place_editable']"
      click :xpath => "//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='in_place_editable']"
      wait_for_element :class => "editor_field"
      type "Megan Weaver", :class => "editor_field"
      submit :class => "inplaceeditor-form"
      wait_for_no_element :class => "editor_field"

      refresh
      wait_for_element "events_table"
      assert_table "events_table", 1, 0, /^Megan Weaver/

      click "past_events"
      assert_table "events_table", 1, 3, /^Copperopolis/

      click "past_events"
      assert_not_in_page_source "Copperopolis"

      assert_table "events_table", 1, 3, /^Lost Series/
      assert_table "events_table", 2, 3, /^National Federation Event/

      # Table already sorted by date ascending, so click doesn't change order
      click :xpath => "//th[@class='date']//a"
      assert_table "events_table", 1, 3, /^Lost Series/
      assert_table "events_table", 2, 3, /^National Federation Event/

      click :xpath => "//th[@class='date']//a"
      assert_table "events_table", 1, 3, /^National Federation Event/
      assert_table "events_table", 2, 3, /^Lost Series/

      click :xpath => "//th[@class='date']//a"
      assert_table "events_table", 1, 3, /^Lost Series/
      assert_table "events_table", 2, 3, /^National Federation Event/    
    end  
  end
end
