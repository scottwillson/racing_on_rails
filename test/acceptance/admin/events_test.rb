require "acceptance/selenium_test_case"

class EventsTest < SeleniumTestCase
  def test_events
    login_as :administrator

    click "link=New Event", :wait_for => :page

    type "event_name", "Sausalito Criterium"
    click "save", :wait_for => :page
    assert_text "Created Sausalito Criterium"
    
    if Date.today.month == 12
      open "/admin/events?year=#{Date.today.year}"
    else
      open "/admin/events"
    end
    assert_text "Sausalito Criterium"
    click "link=Sausalito Criterium", :wait_for => :page

    assert_value "event_promoter_id", ""
    assert_value "promoter_auto_complete", ""
    click "promoter_auto_complete"
    type "promoter_auto_complete", "Tom Brown"

    click "save", :wait_for => :page
    assert_value "event_promoter_id", "regex:\\d+"
    assert_value "promoter_auto_complete", "Tom Brown"

    open "/admin/events?year=#{Date.today.year}"
    assert_text "Sausalito Criterium"
    click "link=Sausalito Criterium", :wait_for => :page
    assert_value "event_promoter_id", "regex:\\d+"
    assert_value "promoter_auto_complete", "Tom Brown"

    click "edit_promoter_link", :wait_for => :page
    assert_title "glob:*Tom Brown"

    type "person_first_name", "Tim"
    click "save", :wait_for => :page

    click "back_to_event", :wait_for => :page

    assert_title "glob:*Sausalito Criterium*"
    assert_value "event_promoter_id", "regex:\\d+"
    assert_value "promoter_auto_complete", "Tim Brown"

    # Need event and timing workarounds for Safari 4
    click "promoter_auto_complete"
    type "promoter_auto_complete", "candi m"
    fire_event "promoter_auto_complete", "keydown"
    fire_event "promoter_auto_complete", "keypress"
    fire_event "promoter_auto_complete", "keyup"
    fire_event "promoter_auto_complete", "change"
    candi = Person.find_by_name('Candi Murray')
    wait_for_element "person_#{candi.id}"
    
    click "person_#{candi.id}"
    assert_value "event_promoter_id", candi.id
    assert_value "promoter_auto_complete", "Candi Murray"

    click "save", :wait_for => :page

    assert_value "event_promoter_id", candi.id
    assert_value "promoter_auto_complete", "Candi Murray"

    click "promoter_auto_complete"
    type "promoter_auto_complete", ""
    fire_event "promoter_auto_complete", "keydown"
    fire_event "promoter_auto_complete", "keypress"
    fire_event "promoter_auto_complete", "keyup"
    fire_event "promoter_auto_complete", "change"
    assert_value "promoter_auto_complete", ""
    click "save", :wait_for => :page

    assert_value "event_promoter_id", ""
    assert_value "promoter_auto_complete", ""

    assert_value "event_team_id", ""
    assert_value "team_auto_complete", ""

    assert_value "event_phone", ""
    assert_value "event_email", ""

    type "event_phone", "(541) 212-9000"
    type "event_email", "event@google.com"
    click "save", :wait_for => :page

    assert_value "event_phone", "(541) 212-9000"
    assert_value "event_email", "event@google.com"

    open "/admin/people/#{candi.id}/edit"
    assert_value "person_home_phone", "(503) 555-1212"
    assert_value "person_email", "admin@example.com"

    open "/admin/events?year=#{Date.today.year}"
    click "link=Sausalito Criterium", :wait_for => :page

    # Need event and timing workarounds for Safari 4
    click "team_auto_complete"
    type "team_auto_complete", "Gentle Lovers"
    fire_event "team_auto_complete", "keydown"
    fire_event "team_auto_complete", "keypress"
    fire_event "team_auto_complete", "keyup"
    fire_event "team_auto_complete", "change"
    wait_for :text =>  "Gentle Lovers"
    gl = Team.find_by_name('Gentle Lovers')
    wait_for_element "team_#{gl.id}"
    click "team_#{gl.id}"
    assert_value "event_team_id", gl.id
    assert_value "team_auto_complete", "Gentle Lovers"

    click "save", :wait_for => :page

    assert_value "event_team_id", gl.id
    assert_value "team_auto_complete", "Gentle Lovers"

    assert_value "event_team_id", gl.id
    click "team_auto_complete"
    type "team_auto_complete", ""
    click "save", :wait_for => :page

    assert_value "event_team_id", ""
    assert_value "team_auto_complete", ""

    click "link=Delete", :wait_for => :page

    assert_text "Deleted Sausalito Criterium"

    open "/admin/events?year=2004"
    assert_no_text "Sausalito Criterium"

    open "/admin/events?year=2003"

    click "link=Kings Valley Road Race", :wait_for => :page
    assert_text "Senior Men Pro 1/2"
    assert_text "Senior Men 3"

    kings_valley = Event.find_by_name_and_date('Kings Valley Road Race', '2003-12-31')
    click "id=destroy_race_#{kings_valley.races.first.id}"

    open "/admin/events?year=2003"
    click "link=Kings Valley Road Race", :wait_for => :page

    click "destroy_races"
    get_confirmation

    open "/admin/events?year=2003"

    click "link=Kings Valley Road Race", :wait_for => :page
    # Selenium breaks delete all races, though it works fine in Safari
    unless selenium.browser_string == "*safari"
      assert_no_text "Senior Men Pro 1/2"
      assert_no_text "Senior Men 3"
    end

    click "new_event", :wait_for => :page
    assert_text "Kings Valley Road Race"
    assert_value "event_parent_id", kings_valley.id

    type "event_name", "Fancy New Child Event"
    click "save", :wait_for => :page
    assert_value "event_parent_id", kings_valley.id

    open "/admin/events/#{kings_valley.id}/edit"
    assert_text "Fancy New Child Event"
  end
  
  def test_lost_children
    login_as :administrator

    open "/admin/events/#{SingleDayEvent.find_by_name('Lost Series').id}/edit"
    assert_text 'has no parent'
    click 'set_parent', :wait_for => :page
    assert_no_text 'error'
    assert_no_text 'Unknown action'
    assert_no_text 'has no parent'
  end
end
