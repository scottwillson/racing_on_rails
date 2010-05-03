require "acceptance/webdriver_test_case"

class EventsTest < WebDriverTestCase
  def test_events
    login_as :administrator

    click :link_text => "New Event"

    type "Sausalito Criterium", "event_name"
    click "save"
    assert_page_source "Created Sausalito Criterium"
    
    if Date.today.month == 12
      open "/admin/events?year=#{Date.today.year}"
    else
      open "/admin/events"
    end
    assert_page_source "Sausalito Criterium"
    click :link_text => "Sausalito Criterium"

    assert_value "", "event_promoter_id"
    assert_value "", "promoter_auto_complete"
    type "Tom Brown", "promoter_auto_complete"

    click "save"
    assert_value(/\d+/, "event_promoter_id")
    assert_value "Tom Brown", "promoter_auto_complete"

    open "/admin/events?year=#{Date.today.year}"
    assert_page_source "Sausalito Criterium"
    click :link_text => "Sausalito Criterium"
    assert_value(/\d+/, "event_promoter_id")
    assert_value "Tom Brown", "promoter_auto_complete"

    click "edit_promoter_link"
    assert_title(/Tom Brown$/)

    type "Tim", "person_first_name"
    click "save"

    click "back_to_event"

    assert_title(/Sausalito Criterium/)
    assert_value(/\d+/, "event_promoter_id")
    assert_value "Tim Brown", "promoter_auto_complete"

    candi = Person.find_by_name('Candi Murray')
    if chrome?
      type "Candi Murray", "promoter_auto_complete"
    else
      # click "promoter_auto_complete"
      type "candi m", "promoter_auto_complete"
      wait_for_element "person_#{candi.id}"

      click "person_#{candi.id}"
      assert_value candi.id, "event_promoter_id"
      assert_value "Candi Murray", "promoter_auto_complete"
    end

    click "save"

    assert_value candi.id, "event_promoter_id"
    assert_value "Candi Murray", "promoter_auto_complete"

    click "promoter_auto_complete"
    type "", "promoter_auto_complete"
    assert_value "", "promoter_auto_complete"
    click "save"

    assert_value "", "event_promoter_id"
    assert_value "", "promoter_auto_complete"

    assert_value "", "event_team_id"
    assert_value "", "team_auto_complete"

    assert_value "", "event_phone"
    assert_value "", "event_email"

    type "(541) 212-9000", "event_phone"
    type "event@google.com", "event_email"
    click "save"

    assert_value "(541) 212-9000", "event_phone"
    assert_value "event@google.com", "event_email"

    open "/admin/people/#{candi.id}/edit"
    assert_value "(503) 555-1212", "person_home_phone"
    assert_value "admin@example.com", "person_email"

    open "/admin/events?year=#{Date.today.year}"
    click :link_text => "Sausalito Criterium"

    # click "team_auto_complete"
    type "Gentle Lovers", "team_auto_complete"
    gl = Team.find_by_name('Gentle Lovers')
    unless chrome?
      wait_for_element "team_#{gl.id}"
      wait_for_displayed "team_#{gl.id}"
      click "team_#{gl.id}"
      assert_value gl.id, "event_team_id"
      assert_value "Gentle Lovers", "team_auto_complete"
    end

    click "save"

    assert_value gl.id, "event_team_id"
    assert_value "Gentle Lovers", "team_auto_complete"

    assert_value gl.id, "event_team_id"
    click "team_auto_complete"
    type "", "team_auto_complete"
    click "save"

    assert_value "", "event_team_id"
    assert_value "", "team_auto_complete"

    click :link_text => "Delete"

    assert_page_source "Deleted Sausalito Criterium"

    open "/admin/events?year=2004"
    assert_not_in_page_source "Sausalito Criterium"

    open "/admin/events?year=2003"

    click :link_text => "Kings Valley Road Race"
    assert_page_source "Senior Men Pro 1/2"
    assert_page_source "Senior Men 3"

    kings_valley = Event.find_by_name_and_date('Kings Valley Road Race', '2003-12-31')
    click "destroy_race_#{kings_valley.races.first.id}"

    open "/admin/events?year=2003"
    click :link_text => "Kings Valley Road Race"

    unless chrome?
      click_ok_on_confirm_dialog
      click "destroy_races"

      open "/admin/events?year=2003"

      click :link_text => "Kings Valley Road Race"
      assert_not_in_page_source "Senior Men Pro 1/2"
      assert_not_in_page_source "Senior Men 3"
    end

    click "new_event"
    wait_for_current_url(/\/events\/new/)
    assert_page_source "Kings Valley Road Race"
    assert_value kings_valley.id, "event_parent_id"

    type "Fancy New Child Event", "event_name"
    click "save"
    assert_value kings_valley.id, "event_parent_id"

    open "/admin/events/#{kings_valley.id}/edit"
    assert_page_source "Fancy New Child Event"
  end
  
  def test_lost_children
    login_as :administrator

    open "/admin/events/#{SingleDayEvent.find_by_name('Lost Series').id}/edit"
    assert_page_source 'has no parent'
    click "set_parent"
    assert_not_in_page_source 'error'
    assert_not_in_page_source 'Unknown action'
    assert_not_in_page_source 'has no parent'
  end
end
