require "acceptance/webdriver_test_case"

class PromotersTest < WebDriverTestCase
  def test_browse
    SingleDayEvent.create! :name => "Cross Crusade: Alpenrose", :promoter => Person.find_by_name("Brad Ross")
    login_as :promoter
    click :link_text => "Cross Crusade: Alpenrose"
  end
end
