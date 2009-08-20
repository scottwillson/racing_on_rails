require "acceptance/selenium_test_case"

class PublicPagesTest < SeleniumTestCase
  def test_popular_pages
    open "/"

    open "/schedule"
    assert_text "regex:Schedule|Calendar"

    open "/schedule/list"
    assert_text "regex:Schedule|Calendar"

    open "/schedule/cyclocross"
    assert_text "regex:Schedule|Calendar"

    open "/schedule/list/cyclocross"
    assert_text "regex:Schedule|Calendar"

    open "/results"
    assert_text "regex:Events|Results"
    assert_text Date.today.year

    open "/results/2004/road"
    assert_text "Kings Valley"

    click "link=Kings Valley Road Race", :wait_for => :page
    assert_text "Kings Valley Road Race"
    assert_text "December 31, 2004"
    assert_text "Senior Women 1/2/3"

    click "link=Pennington", :wait_for => :page

    assert_table "css=table.person_results", 1, 0, "2"
    assert_table "css=table.person_results", 1, 1, "Kings Valley Road Race"
    assert_table "css=table.person_results", 1, 2, "Senior Women 1/2/3"
    assert_text "12/31/2004"

    click "link=Jack Frost", :wait_for => :page
    assert_text "Jack Frost"
    assert_text "January 17, 2002"
    assert_text "Weaver"
    assert_text "Pennington"

    open "/ironman"
    assert_text "Ironman"

    open "/people"
    assert_text "Molly"

    open "/rider_rankings"
    assert_text "No results for #{Date.today.year}"

    open "/cat4_womens_race_series"
    assert_text "No results for #{Date.today.year}"

    open "/oregon_cup"
    assert_text "Oregon Cup"

    open "/teams"
    assert_text "Teams"
    assert_text "Vanilla"

    open "/teams/#{Team.find_by_name('Vanilla').id}"
    assert_text "Vanilla"

    open "/track"

    open "/track/schedule"
  end
  
  def test_bar
    open "/bar"
    assert_text "BAR"
    assert_text 'Oregon Best All-Around Rider'

    open "/bar/2009"
    assert_text "BAR"

    click 'link=Age Graded', :wait_for => :page
    assert_text "#{Date.today.year} Age Graded BAR"
  end
end
