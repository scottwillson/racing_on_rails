require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class PublicPagesTest < AcceptanceTest
  test "popular pages" do
    create_results

    visit "/"
    unless page.has_content?("ATRA") || page.has_content?("WSBA")
      assert_page_has_content("Schedule")
      assert_page_has_content("Results")
    end

    visit "/schedule"
    assert_page_has_content("May")

    visit "/schedule/list"
    assert_page_has_content("Brad Ross")
    assert_page_has_content("(503) 555-1212")

    visit "/schedule/cyclocross"
    unless page.has_content?("Calendar")
      assert_page_has_content("Schedule")
    end

    visit "/schedule/list/cyclocross"
    unless page.has_content?("Calendar")
      assert_page_has_content("Schedule")
    end

    visit "/results"
    assert_page_has_content RacingAssociation.current.effective_year.to_s
    click_link @new_event.name

    visit "/people"

    visit "/teams"
    unless page.has_content?("Member Teams") || page.has_content?("teams in Oregon")
      flunk "Expected Member Teams or teams in Oregon"
    end
    assert_page_has_content "Vanilla"

    visit "/teams/#{Team.find_by_name('Vanilla').id}"
    assert_page_has_content "Vanilla"

    visit "/teams/#{Team.find_by_name('Vanilla').id}/2004"

    visit "/track"

    visit "/track/schedule"
  end

  test "results page" do
    javascript!

    create_results

    visit "/results/2004/road"
    assert_page_has_content "Kings Valley"

    click_link "Kings Valley Road Race"
    assert_page_has_content "Kings Valley Road Race"
    assert_page_has_content "December 31, 2004"
    assert_page_has_content "Senior Women 1/2/3"

    if page.has_content?("Montana")
      wait_for ".panel-default"
      click_link "Senior Women 1/2/3"
      wait_for "table.results a"
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
      wait_for ".panel-default"
      click_link "Senior Men"
      wait_for "table.results a"
      assert_page_has_content "Weaver"
    else
      assert_page_has_content "Weaver"
      assert_page_has_content "Pennington"
    end
  end

  test "people" do
    javascript!

    FactoryGirl.create(:person, name: "Alice Pennington")
    visit "/people"
    assert_page_has_no_content "Pennington"
    assert_page_has_no_content "Weaver"

    unless page.has_content?("Montana")
      fill_in "name", with: "Penn"
      press_return "name"
      assert_page_has_content "Pennington"
    end
  end


  private

  def create_results
    FactoryGirl.create(:discipline, name: "Road")
    FactoryGirl.create(:discipline, name: "Track")
    FactoryGirl.create(:discipline, name: "Time Trial")
    FactoryGirl.create(:discipline, name: "Cyclocross")

    promoter = FactoryGirl.create(:person, name: "Brad Ross", home_phone: "(503) 555-1212")
    @new_event = FactoryGirl.create(:event, promoter: promoter, date: Date.new(RacingAssociation.current.effective_year, 5))
    @alice = FactoryGirl.create(:person, name: "Alice Pennington")
    Timecop.freeze(Date.new(RacingAssociation.current.effective_year, 5, 2)) do
      FactoryGirl.create(:result, event: @new_event)
    end

    FactoryGirl.create(:event, name: "Kings Valley Road Race", date: Time.zone.local(2004).end_of_year.to_date).
      races.create!(category: FactoryGirl.create(:category, name: "Senior Women 1/2/3")).
      results.create!(place: "2", person: @alice)

    event = FactoryGirl.create(:event, name: "Jack Frost", date: Time.zone.local(2002, 1, 17), discipline: "Time Trial")
    event.races.create!(category: FactoryGirl.create(:category, name: "Senior Women")).results.create!(place: "1", person: @alice)
    weaver = FactoryGirl.create(:person, name: "Ryan Weaver")
    event.races.create!(category: FactoryGirl.create(:category, name: "Senior Men")).results.create!(place: "2", person: weaver)

    FactoryGirl.create(:team, name: "Gentle Lovers")
    FactoryGirl.create(:team, name: "Vanilla")
  end
end
