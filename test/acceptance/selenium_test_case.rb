require "test_helper"
require "selenium/client"
require "selenium/client/selenium_helper"

class SeleniumTestCase < ActiveSupport::TestCase
  attr_reader :selenium
  
  # Uses method_missing to route method calls to @selenium
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
    super
  end
    
  def teardown
    close_current_browser_session
    super
  end
end

# Hack. Use our custom TestRunner in place of the default console runner.
# SeleniumTestRunner extends console TestRunner. Main difference is screendumps and snapshots.
# You'd think there would be a easier, cleaner way to do this.
Test::Unit::AutoRunner::RUNNERS[:console] = proc do |r|
  require 'test/unit/ui/selenium_test_runner'
  Test::Unit::UI::SeleniumTestRunner
end
