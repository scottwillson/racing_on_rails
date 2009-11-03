require "acceptance/selenium_test_case"

class ResultsTest < SeleniumTestCase
  def test_results_editing
    login_as :administrator

    click "link=Copperopolis Road Race", :wait_for => :page

    click "link=Senior Men Pro 1/2", :wait_for => :page

    click "result_#{Event.find_by_name('Copperopolis Road Race').races.first.results.first.id}_place", :wait_for => { :element => "css=.editor_field" }
    type "css=.editor_field", "DNF"
    submit "css=.inplaceeditor-form"
    wait_for :element => "css=.editor_field"

    refresh
    wait_for_page
    assert_no_text "13"
    assert_text "DNF"

    click "result_#{Event.find_by_name('Copperopolis Road Race').races.first.results.first.id}_name", :wait_for => { :element => "css=.editor_field" }
    type "css=.editor_field", "Megan Weaver"
    submit "css=.inplaceeditor-form"
    wait_for :element => "css=.editor_field"

    refresh
    wait_for_page
    assert_no_text "Ryan Weaver"
    assert_text "Megan Weaver"

    click "result_#{Event.find_by_name('Copperopolis Road Race').races.first.results.first.id}_team_name", :wait_for => { :element => "css=.editor_field" }
    type "css=.editor_field", "River City"
    submit "css=.inplaceeditor-form"
    wait_for :element => "css=.editor_field"

    refresh
    wait_for_page
    assert_text "River City"

    click "result_#{Event.find_by_name('Copperopolis Road Race').races.first.results.first.id}_add"
    wait_for_ajax
    click "result_#{Event.find_by_name('Copperopolis Road Race').races.first.results.first.id}_destroy", 
          :wait_for => { :element => "result_#{Event.find_by_name('Copperopolis Road Race').races.first.results.first.id.id}_add" }
    refresh
    wait_for_page
    assert_no_text "Megan Weaver"
    assert_text "DNF"

    click "result__add", :wait_for => { :element => "//table[@id='results_table']//tr[1]" }
    refresh
    wait_for_page
    assert_text "Field Size (2)"

    assert_value "race_laps", ""
    type "race_laps", "12"

    click "save", :wait_for => :page

    assert_value "race_laps", "12"
  end
end
