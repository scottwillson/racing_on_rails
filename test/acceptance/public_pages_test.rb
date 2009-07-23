require "acceptance/selenium_test_case"

class PublicPagesTest < SeleniumTestCase
  def test_popular_pages
    open "/"
    assert text?("CBRA")
  end
  
  def test_bar
    open "/bar"
    assert text?("BAR")

    open "/bar/2009"
    assert text?("BAR")
  end
end
