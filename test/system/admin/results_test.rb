# frozen_string_literal: true

require "application_system_test_case"

# :stopdoc:
class ResultsTest < ApplicationSystemTestCase
  test "results editing" do
    FactoryBot.create(:number_issuer, name: RacingAssociation.current.short_name)
    event = FactoryBot.create(:event, name: "Copperopolis Road Race")
    race = FactoryBot.create(:race, event: event)
    result = FactoryBot.create(:result, race: race, name: "Ryan Weaver")

    login_as FactoryBot.create(:administrator)

    if Time.zone.today.month == 12
      visit "/admin/events?year=#{Time.zone.today.year}"
    else
      visit "/admin/events"
    end

    # visit "/admin/events?year=#{Time.zone.today.year - 1}" if Time.zone.today.month == 1 && Time.zone.today.day < 4

    visit_event event

    click_link "edit_race_#{race.id}"

    fill_in_inline "#result_#{result.id}_place", with: "DNF"

    visit "/admin/races/#{race.id}/edit"
    find "#result_#{result.id}_place", text: "DNF"
    fill_in_inline "#result_#{result.id}_name", with: "Megan Weaver"

    visit "/admin/races/#{race.id}/edit"
    assert_no_text "Ryan Weaver"
    assert_page_has_content "Megan Weaver"

    weaver = Person.find_by(name: "Ryan Weaver")
    megan = Person.find_by(name: "Megan Weaver")
    assert weaver != megan, "Should create new person, not rename existing one"

    fill_in_inline "#result_#{result.id}_team_name", with: "River City"

    visit "/admin/races/#{race.id}/edit"
    assert_page_has_content "River City"

    if RacingAssociation.current.competitions.include?(:bar)
      assert_equal true, result.reload.bar?, "bar?"
      assert has_checked_field? "result_#{result.id}_bar"
      uncheck "result_#{result.id}_bar"

      assert_bar_toggled result

      visit "/admin/races/#{race.id}/edit"
      assert_not has_checked_field?("result_#{result.id}_bar")

      check("result_#{result.id}_bar")
      assert_bar_toggled result

      visit "/admin/races/#{race.id}/edit"
      assert has_checked_field?("result_#{result.id}_bar")
    end

    assert page.has_no_selector? :xpath, "//table[@id='results_table']//tr[4]"
    click_link "result_#{result.id}_add"
    assert_selector :xpath, "//table[@id='results_table']//tr[4]"
    find("#result_#{result.id}_destroy").click
    assert_no_selector :xpath, "//table[@id='results_table']//tr[4]"
    visit "/admin/races/#{race.id}/edit"
    assert_no_text "Megan Weaver"
    assert_page_has_content "DNF"

    assert page.has_no_selector? :xpath, "//table[@id='results_table']//tr[4]"
    click_link "result__add"
    assert_selector :xpath, "//table[@id='results_table']//tr[4]"

    visit "/admin/races/#{race.id}/edit"
    assert_page_has_content "Field Size (2)"

    assert_equal "", find_field("race_laps").value
    fill_in "race_laps", with: "12"
    click_button "Save"
    assert_equal "12", find_field("race_laps").value
  end

  def assert_bar_toggled(result)
    bar_was = result.bar?
    begin
      Timeout.timeout(10) do
        sleep 0.25 while result.reload.bar? == bar_was
      end
    rescue Timeout::Error
      raise Timeout::Error, "result.bar? did not change from '#{bar_was}'"
    end
  end
end
