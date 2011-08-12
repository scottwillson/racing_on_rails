require "acceptance/webdriver_test_case"

# :stopdoc:
class PublicPagesTest < WebDriverTestCase
  def test_popular_pages
    open "/"

    open "/schedule"
    assert_page_source(/Schedule|Calendar/)

    open "/schedule/list"
    assert_page_source(/Schedule|Calendar/)

    open "/schedule/cyclocross"
    assert_page_source(/Schedule|Calendar/)

    open "/schedule/list/cyclocross"
    assert_page_source(/Schedule|Calendar/)

    open "/results"
    assert_page_source(/Events|Results/)
    assert_page_source Date.today.year

    open "/results/2004/road"
    assert_page_source "Kings Valley"

    click :link_text => "Kings Valley Road Race"
    assert_page_source "Kings Valley Road Race"
    assert_page_source "December 31, 2004"
    assert_page_source "Senior Women 1/2/3"

    unless find_elements(:link_text => "Pennington").any?
      click :link_text => "Senior Women 1/2/3"
    end
    wait_for_element :link_text => "Pennington"
    wait_for_displayed :link_text => "Pennington"
    click :link_text => "Pennington"
    wait_for_current_url(/people/)
    wait_for_element "person_results"
    assert_table "person_results_table", 1, 0, "2"
    assert_table "person_results_table", 1, 1, "Kings Valley Road Race"
    assert_table "person_results_table", 1, 2, "Senior Women 1/2/3"
 
    open "/people/#{people(:alice).to_param}/2002"
    find_element(:link_text => "Jack Frost").click
    assert_page_source "Jack Frost"
    assert_page_source "January 17, 2002"
    assert_page_source "Weaver"
    assert_page_source "Pennington"

    open "/ironman"
    assert_page_source "Ironman"

    open "/people"
    assert_not_in_page_source "Molly"
    
    type "Molly", :name => "name"
    type :enter, :name => "name"

    open "/rider_rankings"
    assert_page_source "No results for #{Date.today.year}"

    open "/cat4_womens_race_series"
    assert_page_source "No results for #{Date.today.year}"

    open "/oregon_cup"
    assert_page_source "Oregon Cup"

    open "/teams"
    assert_page_source "Teams"
    assert_page_source "Vanilla"

    open "/teams/#{Team.find_by_name('Vanilla').id}"
    assert_page_source "Vanilla"

    open "/teams/#{Team.find_by_name('Vanilla').id}/2004"

    open "/track"

    open "/track/schedule"
  end
  
  def test_bar
    AgeGradedBar.calculate!
    AgeGradedBar.calculate!(2009)
    
    open "/bar"
    assert_page_source "BAR"
    assert_page_source "Oregon Best All-Around Rider"
  
    open "/bar/2009"
    assert_title(/BAR/)
  
    click :link_text => "Age Graded"
    wait_for_current_url(/\/bar\/2009\/age_graded/)
    assert_page_source "Masters Men 30-34"
  
    open "/bar/#{Date.today.year}"
    assert_page_source "Overall"
  
    click :link_text => "Age Graded"
    wait_for_current_url(/age_graded/)
    assert_title(/Age Graded/)
    assert_title(/#{Date.today.year}/)
  end
end
