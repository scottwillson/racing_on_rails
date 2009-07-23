require "test_helper"
require "selenium/client"
require "selenium/client/selenium_helper"

class PublicPagesTest < ActiveSupport::TestCase
  attr_reader :selenium
  
  include Selenium::Client::SeleniumHelper
   
  def setup
    @selenium = Test::Unit::UI::SeleniumTestRunner.selenium(
        :host => "localhost", 
        :port => 4444, 
        :browser => "*firefox", 
        :url => "http://localhost:3000", 
        :timeout_in_second => 60
    )
    start_new_browser_session
  end
    
  def teardown
    close_current_browser_session
  end
  
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

Test::Unit::AutoRunner::RUNNERS[:console] = proc do |r|
  require 'test/unit/ui/selenium_test_runner'
  Test::Unit::UI::SeleniumTestRunner
end
