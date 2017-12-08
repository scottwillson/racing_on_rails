require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class PromotersTest < AcceptanceTest
  test "browse" do
    javascript!

    FactoryBot.create(:discipline, name: "Cyclocross")
    FactoryBot.create(:discipline, name: "Downhill")
    FactoryBot.create(:discipline, name: "Mountain Bike")
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:discipline, name: "Singlespeed")
    FactoryBot.create(:discipline, name: "Track")
    FactoryBot.create(:number_issuer, name: RacingAssociation.current.short_name)

    year = RacingAssociation.current.effective_year
    promoter = FactoryBot.create(:promoter)
    series = Series.create!(name: "Cross Crusade Series", promoter: promoter, date: Date.new(year, 10))
    event = SingleDayEvent.create!(name: "Cross Crusade: Alpenrose", promoter: promoter, date: Date.new(year, 10))
    series.children << event
    login_as promoter

    if page.has_content?("Montana")
      visit "/admin/events/#{series.id}/edit"
    else
      click_link "events_tab"
      click_link "Cross Crusade Series"
    end
    click_button "Save"

    click_link "create_race", match: :first
    within "form.editor_field" do
      fill_in "value", with: "Senior Women\n"
    end
    assert_no_text "form.editor_field input"
    assert_page_has_content "Senior Women"
    race = series.races(true).first
    assert_equal "Senior Women", race.category_name, "Should update category name"

    click_link "edit_race_#{race.id}"
    click_button "Save"

    click_link "events_tab"
    click_link "Cross Crusade: Alpenrose"

    click_link "create_race", match: :first
    within "form.editor_field" do
      fill_in "value", with: "Masters Women 40+\n"
    end
    assert_no_text "form.editor_field input"
    assert_page_has_content "Masters Women 40+"
    race = event.races(true).first
    assert_equal "Masters Women 40+", race.category_name, "Should update category name"

    click_link "edit_race_#{race.id}"
    click_button "Save"

    click_link "people_tab"
    assert_download "export_link", "scoring_sheet.xls"

    visit "/admin/events/#{series.id}/edit"
    click_ok_on_alert_dialog
    click_link "propagate_races"
  end
end
