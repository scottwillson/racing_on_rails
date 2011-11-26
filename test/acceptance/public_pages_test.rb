require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class PublicPagesTest < AcceptanceTest
  def test_popular_pages
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Track")
    FactoryGirl.create(:discipline, :name => "Time Trial")

    promoter = FactoryGirl.create(:person, :name => "Brad Ross", :home_phone => "(503) 555-1212")
    event = FactoryGirl.create(:event, :promoter => promoter)
    FactoryGirl.create(:result, :event => event)

    alice = FactoryGirl.create(:person, :name => "Alice Pennington")
    FactoryGirl.create(:event, :name => "Kings Valley Road Race", :date => Time.zone.local(2004).end_of_year.to_date).
      races.create!(:category => FactoryGirl.create(:category, :name => "Senior Women 1/2/3")).
      results.create!(:place => "2", :person => alice)
    
    event = FactoryGirl.create(:event, :name => "Jack Frost", :date => Time.zone.local(2002, 1, 17), :discipline => "Time Trial")
    event.races.create!(:category => FactoryGirl.create(:category, :name => "Senior Women")).results.create!(:place => "1", :person => alice)
    weaver = FactoryGirl.create(:person, :name => "Ryan Weaver")
    event.races.create!(:category => FactoryGirl.create(:category, :name => "Senior Men")).results.create!(:place => "2", :person => weaver)
    
    FactoryGirl.create(:team, :name => "Gentle Lovers")
    FactoryGirl.create(:team, :name => "Vanilla")

    visit "/"
    assert_page_has_content("Schedule")
    assert_page_has_content("Results")

    visit "/schedule"
    page.driver.browser.navigate.refresh
    assert_page_has_content("January")
    assert_page_has_content("December")

    visit "/schedule/list"
    assert_page_has_content("Brad Ross")
    assert_page_has_content("(503) 555-1212")

    visit "/schedule/cyclocross"
    assert_page_has_content("Schedule")

    visit "/schedule/list/cyclocross"
    assert_page_has_content("Schedule")

    visit "/results"
    assert_page_has_content("Schedule")
    assert_page_has_content Date.today.year.to_s

    visit "/results/2004/road"
    assert_page_has_content "Kings Valley"

    click_link "Kings Valley Road Race"
    assert_page_has_content "Kings Valley Road Race"
    assert_page_has_content "December 31, 2004"
    assert_page_has_content "Senior Women 1/2/3"

    unless page.has_content?("Pennington")
      click_link "Senior Women 1/2/3"
    end
    click_link "Pennington"
    assert_table "person_results_table", 1, 0, "2"
    assert_table "person_results_table", 1, 1, "Kings Valley Road Race"
    assert_table "person_results_table", 1, 2, "Senior Women 1/2/3"

    visit "/people/#{alice.to_param}/2002"
    click_link "Jack Frost"
    assert_page_has_content "Jack Frost"
    assert_page_has_content "January 17, 2002"
    assert_page_has_content "Weaver"
    assert_page_has_content "Pennington"

    visit "/ironman"
    assert_page_has_content "Ironman"

    visit "/people"
    assert_page_has_no_content "Pennington"
    assert_page_has_no_content "Weaver"
    
    fill_in "name", :with => "Penn"

    visit "/rider_rankings"
    assert_page_has_content "No results for #{Date.today.year}"

    visit "/cat4_womens_race_series"
    assert_page_has_content "No results for #{Date.today.year}"

    visit "/oregon_cup"
    assert_page_has_content "Oregon Cup"

    visit "/teams"
    assert_page_has_content "Teams"
    assert_page_has_content "Vanilla"

    visit "/teams/#{Team.find_by_name('Vanilla').id}"
    assert_page_has_content "Vanilla"

    visit "/teams/#{Team.find_by_name('Vanilla').id}/2004"

    visit "/track"

    visit "/track/schedule"
  end
  
  def test_people
    FactoryGirl.create(:person, :name => "Alice Pennington")
    visit "/people"
    assert_page_has_no_content "Pennington"
    assert_page_has_no_content "Weaver"

    fill_in "name", :with => "Penn"
    find_field("name").native.send_keys(:enter)
    assert_page_has_content "Pennington"      
  end
  
  def test_bar
    FactoryGirl.create(:discipline, :name => "Overall")
    FactoryGirl.create(:discipline, :name => "Age Graded")
    AgeGradedBar.calculate!
    AgeGradedBar.calculate!(2009)
    
    visit "/bar"
    assert_page_has_content "BAR"
    assert_page_has_content "Oregon Best All-Around Rider"
  
    visit "/bar/2009"
    page.has_css?("title", :text => /BAR/)
  
    click_link "Age Graded"
    assert_page_has_content "Masters Men 30-34"
  
    visit "/bar/#{Date.today.year}"
    assert_page_has_content "Overall"
  
    click_link "Age Graded"
    page.has_css?("title", :text => /Age Graded/)
  end
end
