require "acceptance/webdriver_test_case"

# :stopdoc:
class PromotersTest < WebDriverTestCase
  def test_browse
    year = RacingAssociation.current.effective_year
    series = Series.create!(:name => "Cross Crusade", :promoter => Person.find_by_name("Brad Ross"), :date => Date.new(year, 10))
    event = SingleDayEvent.create!(:name => "Cross Crusade: Alpenrose", :promoter => Person.find_by_name("Brad Ross"), :date => Date.new(year, 10))
    series.children << event
    login_as :promoter
    
    click "events_tab"
    click :link_text => "Cross Crusade"
    click "save"
    
    click "create_race"
    wait_for_element :css => "td.race"
    type "Senior Women", :css => "form.editor_field input"
    type :return, { :css => "form.editor_field input" }, false
    wait_for_no_element :css => "form.editor_field input"
    wait_for_page_source "Senior Women"
    race = series.races(true).first
    assert_equal "Senior Women", race.category_name, "Should update category name"

    click "edit_race_#{race.id}"
    click "save"

    click "events_tab"
    click :link_text => "Cross Crusade: Alpenrose"
    
    click "create_race"
    wait_for_element :css => "td.race"
    type "Masters Women 40+", :css => ".race form.editor_field input"
    type :return, { :css => ".race form.editor_field input" }, false
    wait_for_no_element :css => ".race form.editor_field input"
    wait_for_page_source "Masters Women 40+"
    race = event.races(true).first
    assert_equal "Masters Women 40+", race.category_name, "Should update category name"

    click "edit_race_#{race.id}"
    click "save"

    click "people_tab"
    remove_download "scoring_sheet.xls"
    click "export_link"
    wait_for_not_current_url(/\/admin\/people.xls\?excel_layout=scoring_sheet&include=members_only/)
    wait_for_download "scoring_sheet.xls"
    assert_no_errors

    click "events_tab"
    click :link_text => "Cross Crusade"
    click_ok_on_alert_dialog
    click "propagate_races"
  end
end
