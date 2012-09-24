require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class ResultsTest < AcceptanceTest
  def test_results_editing
    FactoryGirl.create(:number_issuer, :name => RacingAssociation.current.short_name)
    event = FactoryGirl.create(:event, :name => "Copperopolis Road Race")
    race = FactoryGirl.create(:race, :event => event)
    result = FactoryGirl.create(:result, :race => race, :name => "Ryan Weaver")
    
    login_as FactoryGirl.create(:administrator)

    if Time.zone.today.month == 12
      visit "/admin/events?year=#{Time.zone.today.year}"
    else
      visit "/admin/events"
    end
    
    if Time.zone.today.month == 1 && Time.zone.today.day < 6
      visit "/admin/events?year=#{Time.zone.today.year - 1}"
    end

    click_link "Copperopolis Road Race"

    click_link "edit_race_#{race.id}"

    fill_in_inline "#result_#{result.id}_place", :with => "DNF"

    visit "/admin/races/#{race.id}/edit"
    find "#result_#{result.id}_place", :text => "DNF"
    fill_in_inline "#result_#{result.id}_name", :with => "Megan Weaver"

    visit "/admin/races/#{race.id}/edit"
    assert_page_has_no_content "Ryan Weaver"
    assert_page_has_content "Megan Weaver"
    
    weaver = Person.find_by_name("Ryan Weaver")
    megan = Person.find_by_name("Megan Weaver")
    assert weaver != megan, "Should create new person, not rename existing one"

    fill_in_inline "#result_#{result.id}_team_name", :with => "River City"

    visit "/admin/races/#{race.id}/edit"
    assert_page_has_content "River City"
    
    if RacingAssociation.current.competitions.include? :bar
      assert_equal true, result.reload.bar?, "bar?"
      assert has_checked_field?("result_#{result.id}_bar")
      uncheck("result_#{result.id}_bar")

      begin
        Timeout::timeout(10) do
          until !result.reload.bar?
            sleep 0.25
          end
        end
      rescue Timeout::Error => e
        raise Timeout::Error, "result.bar? did not change to 'false'"
      end

      visit "/admin/races/#{race.id}/edit"
      assert !has_checked_field?("result_#{result.id}_bar")
    
      check("result_#{result.id}_bar")
      begin
        Timeout::timeout(10) do
          until result.reload.bar?
            sleep 0.25
          end
        end
      rescue Timeout::Error => e
        raise Timeout::Error, "result.bar? did not change to 'true'"
      end

      visit "/admin/races/#{race.id}/edit"
      assert has_checked_field?("result_#{result.id}_bar")
    end
    
    assert page.has_no_selector? :xpath, "//table[@id='results_table']//tr[4]"
    click_link "result_#{result.id}_add"
    sleep 0.3
    find("#result_#{result.id}_destroy").click
    visit "/admin/races/#{race.id}/edit"
    assert_page_has_no_content "Megan Weaver"
    assert_page_has_content "DNF"

    click_link "result__add"
    visit "/admin/races/#{race.id}/edit"
    assert_page_has_content "Field Size (2)"

    assert_equal "", find_field("race_laps").value
    fill_in "race_laps", :with => "12"
    click_button "Save"
    assert_equal "12", find_field("race_laps").value
  end
end
