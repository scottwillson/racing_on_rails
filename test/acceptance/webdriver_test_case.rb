# TextMate sets this to 1, which hangs the Firefox driver
ENV.delete "DYLD_FORCE_FLAT_NAMESPACE"

require "test_helper"
require "selenium-webdriver"

class WebDriverTestCase < ActiveSupport::TestCase
  attr_accessor :base_url
  attr_accessor :driver
  
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  fixtures :all
  
  def setup
    FileUtils.rm_rf download_directory
    FileUtils.mkdir_p download_directory
    webdriver_profile = Selenium::WebDriver::Firefox::Profile.new(Rails.root + "test/fixtures/webdriver-profile")
    @driver = Selenium::WebDriver.for(:firefox, :profile => webdriver_profile)
    Test::Unit::UI::WebDriverTestRunner.driver = driver
    @base_url = "http://localhost"
    driver.manage.delete_all_cookies
    super
  end
  
  def teardown
    @driver.try :quit
    super
  end
  
  def open(url, expect_error_page = false)
    driver.get base_url + url
    if expect_error_page
      assert_errors
    else
      assert_no_errors
    end
  end
  
  def refresh
    driver.navigate.refresh
    assert_no_errors
  end
  
  def click(element_finder)
    find_element(element_finder).click
    assert_no_errors
  end
  
  def check(element_finder)
    click element_finder
  end
  
  def submit(element_finder)
    find_element(element_finder).submit
    assert_no_errors
  end
  
  def type(text, element_finder)
    _element = find_element(element_finder)
    _element.clear
    _element.send_keys text
  end
  
  def login_as(person_symbol)
    open "/person_session/new"
    type people(person_symbol).login, "person_session_login"
    type "secret", "person_session_password"
    click "login_button"
    assert_no_errors
  end
  
  def select_option(value, select_element_id)
    find_element(:css => "select##{select_element_id} option[value='#{value}']").select
  end
  
  def click_ok_on_confirm_dialog
    driver.execute_script("window.confirm = function(msg){return true;};")
  end
  
  def assert_no_errors
    assert_not_in_page_source(/Template is missing|Unknown action|Routing Error|RuntimeError|error occurred|Application Trace|RecordNotFound/)
    assert_not_in_title(/Exception/)
  end
  
  def assert_errors
    assert_page_source(/Template is missing|Unknown action|Routing Error|RuntimeError|error occurred|Application Trace|RecordNotFound/)
  end
  
  def assert_page_source(pattern)
    case pattern
    when Regexp
      assert_match pattern, driver.page_source
    else
      assert driver.page_source.include?(pattern.to_s), "Page source should include '#{pattern}'"
    end
  end
  
  def assert_not_in_page_source(pattern)
    case pattern
    when Regexp
      assert_no_match pattern, driver.page_source
    else
      assert !driver.page_source.include?(pattern.to_s), "Page source should not include '#{pattern}'"
    end
  end

  def assert_title(pattern)
    case pattern
    when Regexp
      assert_match pattern, driver.title
    else
      assert driver.title.include?(pattern.to_s), "Page title should include '#{pattern}'"
    end
  end

  def assert_not_in_title(pattern)
    case pattern
    when Regexp
      assert_no_match pattern, driver.title
    else
      assert !driver.title.include?(pattern.to_s), "Page title should not include '#{pattern}'"
    end
  end
  
  def assert_current_url(pattern)
    case pattern
    when Regexp
      assert_match pattern, driver.current_url
    else
      assert driver.current_url.include?(pattern.to_s), "Current URL should include '#{pattern}'"
    end
  end
  
  def assert_element(element_finder)
    assert find_elements(element_finder).any?, "#{element_finder} should be present"
  end
  
  def assert_no_element(element_finder)
    assert find_elements(element_finder).empty?, "#{element_finder} should not be displayed"
  end
  
  def wait_for_element(element_finder)
    raise ArgumentError if element_finder.empty? || element_finder.blank?

    begin
      Timeout::timeout(5) do
        until find_elements(element_finder).any?
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Element #{element_finder} did not appear within 5 seconds"
    end
  end
  
  def wait_for_no_element(element_finder)
    raise ArgumentError if element_finder.empty? || element_finder.blank?

    begin
      Timeout::timeout(5) do
        until find_elements(element_finder).empty?
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Element #{element_finder} did not appear within 5 seconds"
    end
  end
  
  def wait_for_download(glob_pattern)
    raise ArgumentError if glob_pattern.blank? || (glob_pattern.respond_to?(:empty?) && glob_pattern.empty?)
    Timeout::timeout(5) do
      while Dir.glob("#{download_directory}/#{glob_pattern}").empty?
        sleep 0.25
      end
    end
  end
  
  def wait_for_current_url(url_pattern)
    raise ArgumentError if url_pattern.blank? || (url_pattern.respond_to?(:empty?) && url_pattern.empty?)
    Timeout::timeout(5) do
      until driver.current_url.match(url_pattern)
        sleep 0.25
      end
    end
  end
  
  def wait_for_not_current_url(url_pattern)
    raise ArgumentError if url_pattern.blank? || (url_pattern.respond_to?(:empty?) && url_pattern.empty?)
    Timeout::timeout(5) do
      while driver.current_url.match(url_pattern)
        sleep 0.25
      end
    end
  end
  
  def assert_value(value, element_finder)
    element = find_element(element_finder)
    case value
    when Regexp
      assert_match value, element.value
    else
      assert_equal value.to_s, element.value
    end
  end
  
  def assert_checked(element_finder)
    element = find_element(element_finder)
    assert element.selected?, "#{element_finder.inspect} should be checked"
  end
  
  def assert_not_checked(element_finder)
    element = find_element(element_finder)
    assert !element.selected?, "#{element_finder.inspect} should not be checked"
  end
  
  def assert_text(text, element_finder)
    element = find_element(element_finder)
    case text
    when Regexp
      assert_match text, element.text
    else
      assert_equal text.to_s, element.text
    end
  end
  
  def assert_table(table_id, row, column, expected)
    element = find_element(:xpath => "//table[@id='#{table_id}']//tr[#{row + 1}]//td[#{column + 1}]")
    case expected
    when Regexp
      assert_match expected, element.text, "Row #{row} column #{column} of table #{table_id}"
    else
      assert_equal expected.to_s, element.text, "Row #{row} column #{column} of table #{table_id}"
    end
  end
  
  def drag_and_drop_by(right_by, down_by, element_finder)
    find_element(element_finder).drag_and_drop_by right_by, down_by
  end
  
  def find_element(element_finder)
    case element_finder
    when Hash
      driver.find_element element_finder.dup
    else
      driver.find_element :id => element_finder.dup
    end
  end
  
  def find_elements(element_finder)
    case element_finder
    when Hash
      driver.find_elements element_finder.dup
    else
      driver.find_elements :id => element_finder.dup
    end
  end
  
  def download_directory
    @download_directory ||= "/tmp/webdriver-downloads"
  end
end

# Hack. Use our custom TestRunner in place of the default console runner.
# SeleniumTestRunner extends console TestRunner. Main difference is screendumps and snapshots.
# You'd think there would be a easier, cleaner way to do this.
Test::Unit::AutoRunner::RUNNERS[:console] = proc do |r|
  require 'test/unit/ui/webdriver_test_runner'
  Test::Unit::UI::WebDriverTestRunner
end
