require "acceptance/webdriver_test_case"

class ResultsTest < WebDriverTestCase
  def test_results_editing
    login_as :administrator

    if Date.today.month == 12
      open "/admin/events?year=#{Date.today.year}"
    else
      open "/admin/events"
    end

    click :link_text => "Copperopolis Road Race"
    wait_for_current_url(/\/admin\/events\/\d+\/edit/)

    click :link_text => "Senior Men Pro 1/2"
    wait_for_current_url(/\/admin\/races\/\d+\/edit/)

    result_id = Event.find_by_name('Copperopolis Road Race').races.first.results.first.id
    click "result_#{result_id}_place"
    wait_for_element :class_name => "editor_field"
    type "DNF", :class_name => "editor_field"
    submit :class_name => "inplaceeditor-form"
    wait_for_no_element :class_name => "editor_field"

    refresh
    wait_for_element "results_table"
    assert_text "DNF", "result_#{result_id}_place"

    click "result_#{result_id}_name"
    wait_for_element :class_name => "editor_field"
    type "Megan Weaver", :class_name => "editor_field"
    submit :class_name => "inplaceeditor-form"
    wait_for_no_element :class_name => "editor_field"

    refresh
    wait_for_element "results_table"
    assert_not_in_page_source "Ryan Weaver"
    assert_page_source "Megan Weaver"

    click "result_#{result_id}_team_name"
    wait_for_element :class_name => "editor_field"
    type "River City", :class_name => "editor_field"
    submit :class_name => "inplaceeditor-form"
    wait_for_no_element :class_name => "editor_field"

    refresh
    wait_for_element "results_table"
    assert_page_source "River City"

    assert_no_element :xpath => "//table[@id='results_table']//tr[4]"
    click "result_#{result_id}_add"
    wait_for_element :xpath => "//table[@id='results_table']//tr[4]"
    click "result_#{result_id}_destroy"
    wait_for_no_element :xpath => "//table[@id='results_table']//tr[4]"
    refresh
    wait_for_element "results_table"
    assert_not_in_page_source "Megan Weaver"
    assert_page_source "DNF"

    click "result__add"
    wait_for_element :xpath => "//table[@id='results_table']//tr[4]"
    refresh
    wait_for_element "results_table"
    assert_page_source "Field Size (2)"

    assert_value "", "race_laps"
    type "12", "race_laps"

    click "save"

    wait_for_element "race_laps"
    assert_value "12", "race_laps"
  end
end
