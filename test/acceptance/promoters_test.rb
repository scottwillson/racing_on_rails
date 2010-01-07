require "acceptance/selenium_test_case"

class PromotersTest < SeleniumTestCase
  def test_browse
    SingleDayEvent.create!(:name => "Cross Crusade: Alpenrose", :promoter => Person.find_by_name("Brad Ross"))
    
    login_as :promoter

    click "link=Cross Crusade: Alpenrose", :wait_for => :page
  end
end