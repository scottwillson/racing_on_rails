require "acceptance/selenium_test_case"

class PublicPagesTest < SeleniumTestCase
  def test_popular_pages
    open "/"
  end
  
  def test_bar
    open "/bar"
    assert_text "BAR"

    open "/bar/2009"
    assert_text "BAR"
  end
end
