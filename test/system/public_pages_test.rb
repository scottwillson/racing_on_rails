# frozen_string_literal: true

require "application_system_test_case"

# :stopdoc:
class PublicPagesTest < ApplicationSystemTestCase
  test "popular pages" do
    create_results

    visit "/"
    unless page.has_content?("ATRA") || page.has_content?("WSBA")
      assert_page_has_content("SCHEDULE")
      assert_page_has_content("Results")
    end

    visit "/schedule"
    assert_page_has_content("May")

    visit "/schedule/list"
    assert_page_has_content("Brad Ross")
    assert_page_has_content("(503) 555-1212")

    visit "/schedule/cyclocross"
    assert_page_has_content("SCHEDULE") unless page.has_content?("Calendar")

    visit "/schedule/list/cyclocross"
    assert_page_has_content("SCHEDULE") unless page.has_content?("Calendar")

    visit "/results"
    assert_page_has_content RacingAssociation.current.effective_year.to_s
    click_link @new_event.name

    visit "/people"

    visit "/teams"
    flunk "Expected Member Teams or teams in Oregon" unless page.has_content?("Member Teams") || page.has_content?("teams in Oregon")
    assert_page_has_content "Vanilla"

    visit "/teams/#{Team.find_by(name: 'Vanilla').id}"
    assert_page_has_content "Vanilla"

    visit "/teams/#{Team.find_by(name: 'Vanilla').id}/2004"
  end

  test "results page" do
    create_results

    visit "/results/2004/road"
    assert_page_has_content "Kings Valley"

    click_link "Kings Valley Road Race"
    assert_page_has_content "Kings Valley Road Race"
    assert_page_has_content "December 31, 2004"
    assert_page_has_content "Senior Women 1/2/3"

    if page.has_content?("Montana")
      assert_selector ".panel-default"
      click_link "Senior Women 1/2/3"
      assert_selector "table.results a"
    end
    click_link "Pennington"
    assert find("table.results td.place").has_text?("2")
    assert find("table.results td.event").has_text?("Kings Valley Road Race")
    assert find("table.results td.category").has_text?("Senior Women 1/2/3")

    visit "/people/#{@alice.to_param}/2002"
    click_link "Jack Frost"
    assert_page_has_content "Jack Frost"
    assert_page_has_content "January 17, 2002"
    if page.has_content?("Montana")
      assert_selector ".panel-default"
      click_link "Senior Men"
      assert_selector "table.results a"
      assert_page_has_content "Weaver"
    else
      assert_page_has_content "Weaver"
      assert_page_has_content "Pennington"
    end
  end

  test "people" do
    FactoryBot.create(:person, name: "Alice Pennington")
    visit "/people"
    assert_no_text "Pennington"
    assert_no_text "Weaver"

    unless page.has_content?("Montana")
      fill_in "name", with: "Penn\n"
      assert_page_has_content "Pennington"
    end
  end

  private

  def create_results
    FactoryBot.create(:discipline, name: "Road")
    FactoryBot.create(:discipline, name: "Track")
    FactoryBot.create(:discipline, name: "Time Trial")
    FactoryBot.create(:discipline, name: "Cyclocross")
    FactoryBot.create(:discipline, name: "Mountain Bike")

    promoter = FactoryBot.create(:person, name: "Brad Ross", home_phone: "(503) 555-1212")
    @new_event = FactoryBot.create(:event, promoter: promoter, date: Date.new(RacingAssociation.current.effective_year, 5))
    @alice = FactoryBot.create(:person, name: "Alice Pennington")
    Timecop.freeze(Date.new(RacingAssociation.current.effective_year, 5, 2)) do
      FactoryBot.create(:result, event: @new_event)
    end

    FactoryBot.create(:event, name: "Kings Valley Road Race", date: Time.zone.local(2004).end_of_year.to_date)
              .races.create!(category: FactoryBot.create(:category, name: "Senior Women 1/2/3"))
              .results.create!(place: "2", person: @alice)

    event = FactoryBot.create(:event, name: "Jack Frost", date: Time.zone.local(2002, 1, 17), discipline: "Time Trial")
    event.races.create!(category: FactoryBot.create(:category, name: "Senior Women")).results.create!(place: "1", person: @alice)
    weaver = FactoryBot.create(:person, name: "Ryan Weaver")
    event.races.create!(category: FactoryBot.create(:category, name: "Senior Men")).results.create!(place: "2", person: weaver)

    FactoryBot.create(:team, name: "Gentle Lovers")
    FactoryBot.create(:team, name: "Vanilla")
  end
end
