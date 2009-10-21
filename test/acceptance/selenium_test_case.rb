require "test_helper"
require "selenium/client"
require "selenium/client/selenium_helper"

class SeleniumTestCase < ActiveSupport::TestCase
  attr_reader :selenium
  
  # Uses method_missing to route method calls to @selenium
  include Selenium::Client::SeleniumHelper
   
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  fixtures :all

  def setup
    browser = case RUBY_PLATFORM
    when /darwin/i
      "*safari"
    when /windows/i
      "*iexplorer"
    when /freebsd/i
      "*firefox /usr/local/lib/firefox3/firefox-bin"
    else
      "*firefox"
    end
    
    @selenium = Test::Unit::UI::SeleniumTestRunner.selenium(
        :host => "localhost", 
        :port => 4444, 
        :browser => browser, 
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
    close_current_browser_session rescue nil
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
  def open(url, options = {})
    selenium.open(url)
    wait_for_page
    if options[:assert] == :error
      assert_errors
    else
      assert_no_errors
    end
  end
  
  def click(locator, options={})    
    super(locator, options)
    assert_no_errors if options[:wait_for] && options[:wait_for] == :page
  end
  
  def submit_and_wait(locator)
    submit locator
    wait_for_page
  end
  
  def wait_for_not_location(pattern)
    string_command "waitForNotLocation", [pattern]
  end
  
  def assert_no_errors
    assert_no_text "regexp:Template is missing|Unknown action|Routing Error|RuntimeError|error occurred|Application Trace|RecordNotFound"
    assert_not_title "regexp:Exception"
  end
  
  def assert_errors
    assert_text "regexp:Template is missing|Unknown action|Routing Error|RuntimeError|error occurred|Application Trace|RecordNotFound"
  end
  
  def assert_text(pattern)
    assert text?(pattern), "Did not find '#{pattern}' in response"
  end
  
  def assert_no_text(pattern)
    assert !text?(pattern), "Found '#{pattern}' in response"
  end
  
  def assert_element_text(locator, pattern)
    string_command "assertText", [locator, pattern]
  end
  
  def assert_title(pattern)
    string_command "assertTitle", [pattern]
  end
  
  def assert_not_title(pattern)
    string_command "assertNotTitle", [pattern]
  end
  
  def assert_present(locator)
    string_command "assertElementPresent", [locator]
  end
  
  def assert_not_present(locator)
    string_command "assertElementNotPresent", [locator]
  end
  
  def assert_value(locator, pattern)
    string_command "assertValue", [locator, pattern]
  end
  
  # rows and coluns are 1-based
  def assert_table locator, row, column, expected
    string_command "assertTable", ["#{locator}.#{row}.#{column}", expected]
  end
  
  def assert_location(pattern)
    string_command "assertLocation", [pattern]
  end
  
  def assert_checked(locator)
    string_command "assertChecked", [locator]
  end
  
  def assert_not_checked(locator)
    string_command "assertNotChecked", [locator]
  end
end

# Hack. Use our custom TestRunner in place of the default console runner.
# SeleniumTestRunner extends console TestRunner. Main difference is screendumps and snapshots.
# You'd think there would be a easier, cleaner way to do this.
Test::Unit::AutoRunner::RUNNERS[:console] = proc do |r|
  require 'test/unit/ui/selenium_test_runner'
  Test::Unit::UI::SeleniumTestRunner
end
