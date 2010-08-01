require "acceptance/webdriver_test_case"

# :stopdoc:
class PromotersTest < WebDriverTestCase
  def test_browse
    series = Series.create!(:name => "Cross Crusade", :promoter => Person.find_by_name("Brad Ross"))
    event = SingleDayEvent.create!(:name => "Cross Crusade: Alpenrose", :promoter => Person.find_by_name("Brad Ross"))
    series.children << event
    login_as :promoter
    
    click "events_tab"
    click :link_text => "Cross Crusade"
    click "save"
    
    click "create_race"
    wait_for_element :css => "td.race"
    type "Senior Women", :css => "form.editor_field input"
    type :return, { :css => "form.editor_field input" }, false
    wait_for_no_element :class_name => "editor_field"
    wait_for_no_element :css => "form.editor_field input"
    race = series.races(true).first
    assert_equal "Senior Women", race.category_name, "Should update category name"

    click "edit_race_#{race.id}"
    click "save"

    click "events_tab"
    click :link_text => "Cross Crusade: Alpenrose"

    click "people_tab"
    remove_download "scoring_sheet.xls"
    click "export_link"
    wait_for_not_current_url(/\/admin\/people.xls\?excel_layout=scoring_sheet&include=members_only/)
    wait_for_download "scoring_sheet.xls"
    assert_no_errors

    click "events_tab"
    click :link_text => "Cross Crusade"
    click "propagate_races"
  end
end
