require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class EventsTest < AcceptanceTest
  def test_events
    candi = FactoryGirl.create(:person, :name => "Candi Murray", :home_phone => "(503) 555-1212", :email => "admin@example.com")
    gl = FactoryGirl.create(:team, :name => "Gentle Lovers")
    kings_valley = FactoryGirl.create(:event, :name => "Kings Valley Road Race", :date => "2003-12-31")
    race_1 = kings_valley.races.create!(:category => FactoryGirl.create(:category, :name => "Senior Men Pro 1/2"))
    kings_valley.races.create!(:category => FactoryGirl.create(:category, :name => "Senior Men 3"))

    login_as FactoryGirl.create(:administrator)

    click_link "New Event"

    fill_in "event_name", :with => "Sausalito Criterium"
    click_button "Save"
    assert_page_has_content "Created Sausalito Criterium"
    
    visit "/admin/events"
    assert_page_has_content "Sausalito Criterium"
    click_link "Sausalito Criterium"

    assert_equal "", find("#event_promoter_id").value
    assert_equal "", find("#promoter_auto_complete").value
    find("#promoter_auto_complete").native.send_keys("Tom Brown")

    click_button "Save"
    assert_match %r{\d+}, find("#event_promoter_id").value
    assert page.has_field?("promoter_auto_complete", :with => "Tom Brown")

    visit "/admin/events"
    assert_page_has_content "Sausalito Criterium"
    click_link "Sausalito Criterium"
    assert_match %r{\d+}, find("#event_promoter_id").value
    assert page.has_field?("promoter_auto_complete", :with => "Tom Brown")

    click_link "edit_promoter_link"
    assert page.has_field?("First Name", :with => "Tom")
    assert page.has_field?("Last Name", :with => "Brown")

    fill_in "First Name", :with => "Tim"
    click_button "Save"

    click_link "back_to_event"

    assert_match %r{\d+}, find("#event_promoter_id").value
    assert page.has_field?("promoter_auto_complete", :with => "Tim Brown")

    fill_in "promoter_auto_complete", :with => "candi m"
    find("li#person_#{candi.id} a").click
    assert page.has_field?("promoter_auto_complete", :with => "Candi Murray")

    click_button "Save"

    assert_equal candi.id.to_s, find("#event_promoter_id").value
    assert page.has_field?("promoter_auto_complete", :with => "Candi Murray")

    fill_in "promoter_auto_complete", :with => ""
    click_button "Save"

    assert_equal "", find("#event_promoter_id").value
    assert page.has_field?("promoter_auto_complete", :with => "")

    assert_equal "", find("#event_team_id").value
    assert_equal "", find("#team_auto_complete").value

    assert_equal "", find("#event_phone").value
    assert_equal "", find("#event_email").value

    fill_in "event_phone", :with => "(541) 212-9000"
    fill_in "event_email", :with => "event@google.com"
    click_button "Save"

    assert page.has_field?("event_phone", :with => "(541) 212-9000")
    assert page.has_field?("event_email", :with => "event@google.com")

    visit "/admin/people/#{candi.id}/edit"
    assert page.has_field?("person_home_phone", :with => "(503) 555-1212")
    assert page.has_field?("person_email", :with => "admin@example.com")

    visit "/admin/events"
    click_link "Sausalito Criterium"

    fill_in "team_auto_complete", :with => "Gentle Lovers"
    find("li#team_#{gl.id} a").click
    assert page.has_field?("team_auto_complete", :with => "Gentle Lovers")

    click_button "Save"

    assert_equal gl.id.to_s, find("#event_team_id").value
    assert_equal "Gentle Lovers", find("#team_auto_complete").value

    fill_in "team_auto_complete", :with => ""
    click_button "Save"

    assert_equal "", find("#event_team_id").value
    assert_equal "", find("#team_auto_complete").value

    click_link "Delete"

    assert_page_has_content "Deleted Sausalito Criterium"

    visit "/admin/events?year=2004"
    assert_page_has_no_content "Sausalito Criterium"

    visit "/admin/events?year=2003"

    assert_page_has_content "Import Schedule"
    click_link "Kings Valley Road Race"
    assert_page_has_content "Senior Men Pro 1/2"
    assert_page_has_content "Senior Men 3"

    kings_valley = Event.find_by_name_and_date("Kings Valley Road Race", "2003-12-31")
    click_link "destroy_race_#{race_1.id}"

    visit "/admin/events?year=2003"
    click_link "Kings Valley Road Race"

    click_ok_on_confirm_dialog
    click_link "destroy_races"

    visit "/admin/events?year=2003"

    click_link "Kings Valley Road Race"
    assert_page_has_no_content "Senior Men Pro 1/2"
    assert_page_has_no_content "Senior Men 3"

    click_link "new_event"
    assert_page_has_content "Kings Valley Road Race"
    assert_equal kings_valley.to_param, find("#event_parent_id").value

    fill_in "event_name", :with => "Fancy New Child Event"
    click_button "Save"
    assert_equal kings_valley.to_param, find("#event_parent_id").value

    visit "/admin/events/#{kings_valley.id}/edit"
    assert_page_has_content "Fancy New Child Event"
  end
  
  def test_lost_children
    login_as FactoryGirl.create(:administrator)
    FactoryGirl.create(:series, :name => "PIR")
    event = FactoryGirl.create(:event, :name => "PIR")
    
    visit "/admin/events/#{event.id}/edit"
    assert_page_has_content "has no parent"
    click_link "set_parent"
    assert_page_has_no_content "error"
    assert_page_has_no_content "Unknown action"
    assert_page_has_no_content "has no parent"
  end
end
