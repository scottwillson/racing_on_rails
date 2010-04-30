require "acceptance/webdriver_test_case"

class PromotersTest < WebDriverTestCase
  def test_browse
    SingleDayEvent.create! :name => "Cross Crusade: Alpenrose", :promoter => Person.find_by_name("Brad Ross")
    login_as :promoter
    
    click "events_tab"
    click :link_text => "Cross Crusade: Alpenrose"

    click "people_tab"
    remove_download "scoring_sheet.xls"
    click "export_link"
    wait_for_not_current_url(/\/admin\/people.xls\?excel_layout=scoring_sheet&include=members_only/)
    wait_for_download "scoring_sheet.xls"
    assert_no_errors
  end
end
