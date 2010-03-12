require "acceptance/webdriver_test_case"

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

    click :link_text => "Pennington"
    
    assert_equal "2", find_element(:css => "table.person_results").first(:css => "td.place").text
    assert_equal "Kings Valley Road Race", find_element(:css => "table.person_results").first(:css => "td.standings").text
    assert_equal "Senior Women 1/2/3", find_element(:css => "table.person_results").first(:css => "td.category").text
    assert_equal "12/31/2004", find_element(:css => "table.person_results").first(:css => "td.dates").text

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
    submit :id => "search_form"

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
    assert_page_source "Masters Men 30-34"
  
    open "/bar/#{Date.today.year}"
    assert_page_source "Overall"
  
    click :link_text => "Age Graded"
    assert_title(/Age Graded/)
    assert_title(/#{Date.today.year}/)
  end
end
