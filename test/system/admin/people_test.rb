# frozen_string_literal: true

require "application_system_test_case"

# :stopdoc:
class PeopleTest < ApplicationSystemTestCase
  test "edit" do
    FactoryBot.create(:discipline)
    FactoryBot.create(:mtb_discipline)
    FactoryBot.create(:number_issuer, name: RacingAssociation.current.short_name)
    administrator = FactoryBot.create(:administrator, name: "Candi Murray")
    login_as administrator
    molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron", team_name: "Vanilla", license: "202")
    molly.aliases.create!(name: "Mollie Cameron")
    FactoryBot.create(:result, person: molly)
    matson = FactoryBot.create(:person, first_name: "Mark", last_name: "Matson", team_name: "Kona", license: "340", road_number: "765")
    alice = FactoryBot.create(:person, first_name: "Alice", last_name: "Pennington", team_name: "Gentle Lovers", license: "230")
    brad = FactoryBot.create(:person, first_name: "Brad", last_name: "Ross")
    weaver = FactoryBot.create(:person, first_name: "Ryan", last_name: "Weaver", team_name: "Gentle Lovers", license: "341")

    visit "/admin/people"
    fill_in "name", with: "a\n"

    assert_table("people_table", 1, 2, "Molly Cameron")
    assert_table("people_table", 2, 2, "Mark Matson")
    assert_table("people_table", 3, 2, "Candi Murray")
    assert_table("people_table", 4, 2, "Alice Pennington")
    assert_table("people_table", 5, 2, "Brad Ross")
    assert_table("people_table", 6, 2, "Ryan Weaver")

    assert_table("people_table", 1, 3, "Vanilla")
    assert_table("people_table", 2, 3, "Kona")
    assert_table("people_table", 4, 3, "Gentle Lovers")
    assert_table("people_table", 6, 3, "Gentle Lovers")

    assert_table("people_table", 1, 4, "Mollie Cameron")
    assert_table "people_table", 2, 4, ""
    assert_table "people_table", 3, 4, ""
    assert_table "people_table", 4, 4, ""
    assert_table "people_table", 5, 4, ""

    assert_table "people_table", 1, 5, "202"
    assert_table "people_table", 2, 5, "340"
    assert_table "people_table", 3, 5, ""
    assert_table "people_table", 4, 5, "230"
    assert_table "people_table", 5, 5, ""
    assert_table "people_table", 6, 5, "341"

    assert has_checked_field?("person_member_#{molly.id}")
    assert has_checked_field?("person_member_#{weaver.id}")
    assert has_checked_field?("person_member_#{matson.id}")
    assert has_checked_field?("person_member_#{alice.id}")

    fill_in_inline "#person_#{alice.id}_name", with: "A Penn"
    visit "/admin/people"
    assert_table("people_table", 4, 2, "A Penn")
    assert_table("people_table", 4, 4, "Alice Pennington")

    fill_in_inline "#person_#{weaver.id}_team_name", with: "River City Bicycles"
    visit "/admin/people"
    assert_table("people_table", 6, 3, "River City Bicycles")

    click_link "#{molly.id}_results"
    assert_equal "Molly Cameron", find("h2").text

    visit "/admin/people"
    click_link "#{weaver.id}_results"
    assert_equal "Ryan Weaver", find("h2").text

    visit "/admin/people"
    click_link "edit_#{matson.id}"
    assert_equal "Mark Matson", find("h2").text
    fill_in "person_home_phone", with: "411 911 1212"
    click_button "Save"

    first("a[href='/people/#{matson.id}/versions']").click

    visit "/admin/people"
    click_link "new_person"

    matson.race_numbers.create!(value: "878", year: 2009)
    visit "/admin/people/#{matson.id}/edit"
    assert_page_has_content "Mark Matson"
    if Time.zone.today.month < 12
      assert_selector "input.number[value='765']"
      click_link "destroy_number_#{matson.race_numbers.first.id}"
      assert_no_selector "input.number[value='765']"

      click_button "Save"

      assert_no_text "error"
      assert_no_text "Unknown action"
      assert_no_text "Couldn't find RaceNumber"
    end

    assert !page.has_css?("input.number[value='878']")
    select "2009", from: "number_year"
    assert page.has_css?("input.number[value='878']")

    visit "/admin/people/#{brad.id}/edit"
    assert_page_has_content "Ross"
    click_link "delete"
    assert_no_text "error"
    assert_no_text "Unknown action"
    assert_no_text "has no parent"

    fill_in "name", with: "Brad\n"
    assert_no_text "Ross"

    visit "/admin/people"
    fill_in "name", with: "a\n"

    find("#person_#{alice.id}").drag_to(find("#person_#{molly.id}_row"))
    assert_content "Merged A Penn into Molly Cameron"
    assert page.has_selector?(".alert-info")
    assert page.has_no_selector?(".alert-danger")
    assert !Person.exists?(alice.id), "Alice should be merged"
    assert Person.exists?(molly.id), "Molly still exist after merge"
  end

  test "merge confirm" do
    login_as FactoryBot.create(:administrator, name: "Candi Murray")
    FactoryBot.create(:person, name: "Molly Cameron")
    FactoryBot.create(:person, name: "Mark Matson")

    visit "/admin/people"
    fill_in "name", with: "a\n"

    assert_table("people_table", 1, 2, "Molly Cameron")
    assert_table("people_table", 2, 2, "Mark Matson")

    molly = Person.find_by(name: "Molly Cameron")
    matson = Person.find_by(name: "Mark Matson")

    fill_in_inline "#person_#{matson.id}_name", with: "Molly Cameron", assert_edit: false

    find(".ui-dialog-buttonset button:last-child").click

    assert Person.exists?(molly.id), "Should not have merged Molly"
    assert Person.exists?(matson.id), "Should not have merged Matson"
    assert !molly.aliases.reload.map(&:name).include?("Mark Matson"), "Should not add Matson alias"

    visit "/admin/people"
    press_return "name"
    assert_selector_ajax
    assert_selector "#people_table"
    assert_table("people_table", 1, 2, "Molly Cameron")
    assert_table("people_table", 2, 2, "Mark Matson")
    press_return "name"
    assert_selector_ajax
    assert_selector "#people_table"
    assert_table("people_table", 1, 2, "Molly Cameron")
    assert_table("people_table", 2, 2, "Mark Matson")

    fill_in_inline "#person_#{matson.id}_name", with: "Molly Cameron", assert_edit: false
    assert_selector ".ui-dialog-buttonset button:first-child"
    find(".ui-dialog-buttonset button:first-child").click

    assert_page_has_content "Merged Mark Matson into Molly Cameron"
    assert Person.exists?(molly.id), "Should not have merged Molly"
    assert !Person.exists?(matson.id), "Should have merged Matson"
    assert molly.aliases.reload.map(&:name).include?("Mark Matson"), "Should add Matson alias"
  end

  test "export" do
    FactoryBot.create(:discipline, name: "Cyclocross")
    FactoryBot.create(:discipline, name: "Downhill")
    FactoryBot.create(:discipline, name: "Mountain Bike")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:discipline, name: "Singlespeed")
    FactoryBot.create(:discipline, name: "Track")
    FactoryBot.create(:number_issuer, name: RacingAssociation.current.short_name)

    FactoryBot.create(:person, name: "Erik Tonkin", team_name: "Kona", license: "102")

    login_as FactoryBot.create(:administrator)

    visit "/admin/people"
    assert page.has_selector? "#export_button"
    assert page.has_selector? "#include"
    assert page.has_field? "include", with: "members_only"
    assert page.has_field? "format", with: "xls"

    today = RacingAssociation.current.effective_today
    assert_download "export_button", "people_#{RacingAssociation.current.effective_year}_#{today.month}_#{today.day}.xls"

    visit "/admin/teams"

    visit "/admin/people"

    fill_in "name", with: "tonkin\n"
    assert_page_has_content "Erik Tonkin"
    assert_page_has_content "Kona"
    assert_page_has_content "102" if Time.zone.today.month < 12
    assert page.has_field? "name", with: "tonkin"

    select "All", from: "include"
    select "FinishLynx", from: "format"
    assert_download "export_button", "lynx.ppl"

    visit "/admin/people"
    select "Current members only", from: "include"
    select "Scoring sheet", from: "format"
    assert_download "export_button", "scoring_sheet.xls"

    fill_in "name", with: "tonkin\n"
    assert_page_has_content "Erik Tonkin"
    assert_page_has_content "Kona"
    assert_page_has_content "102" if Time.zone.today.month < 12
    assert page.has_field? "name", with: "tonkin"
  end

  test "import" do
    login_as FactoryBot.create(:administrator)
    visit "/admin/people"
    attach_file "people_file", "#{Rails.root}/test/fixtures/membership/upload.xlsx"
  end
end
