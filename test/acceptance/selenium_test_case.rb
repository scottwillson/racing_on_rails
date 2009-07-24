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

    delete_cookie '_racing_on_rails_session_id', '/'
    delete_cookie 'auth_token', '/'
    delete_cookie 'email', '/'
    delete_cookie 'person_name', '/'
    delete_cookie 'team_name', '/'

    super
  end
    
  def teardown
    close_current_browser_session
    super
  end
  
  def login_as_admin
    open "/person_session/new"
    type "person_session_login", "admin@example.com"
    type "person_session_password", "secret"
    click "login_button", :wait_for => :page
    assert_no_errors
    assert_location "*/admin/events"
  end
  
  # Check page has no error
  def open(url)
    selenium.open(url)
    assert_no_errors
  end
  
  def assert_no_errors
    assert_no_text "regexp:Template is missing|Unknown action|Routing Error|RuntimeError|error occurred|Application Trace|RecordNotFound"
    assert_not_title "regexp:Exception"
  end
  
  def assert_text(pattern)
    assert text?(pattern), "Did not find '#{pattern}' in response"
  end
  
  def assert_no_text(pattern)
    assert !text?(pattern), "Found '#{pattern}' in response"
  end
  
  def assert_not_title(pattern)
    string_command "assertNotTitle", [pattern]
  end
  
  # rows and coluns are 1-based
  def assert_table locator, row, column, expected
    string_command "assertTable", ["#{locator}.#{row}.#{column}", expected]
  end
  
  def assert_location(pattern)
    string_command "assertLocation", [pattern]
  end
end

# Hack. Use our custom TestRunner in place of the default console runner.
# SeleniumTestRunner extends console TestRunner. Main difference is screendumps and snapshots.
# You'd think there would be a easier, cleaner way to do this.
Test::Unit::AutoRunner::RUNNERS[:console] = proc do |r|
  require 'test/unit/ui/selenium_test_runner'
  Test::Unit::UI::SeleniumTestRunner
end
