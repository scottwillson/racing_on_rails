# TextMate sets this to 1, which hangs the Firefox driver
ENV.delete "DYLD_FORCE_FLAT_NAMESPACE"

require File.expand_path("../../test_helper", __FILE__)
require File.expand_path(File.dirname(__FILE__) + "/webdriver_test_unit")
require "selenium-webdriver"

MiniTest::Unit.after_tests {
  begin
    begin
      Timeout::timeout(5) do
        MiniTest::Unit.driver.try :quit
      end
    rescue Timeout::Error => e
      Rails.logger.warn "Could not quit Firefox driver"
      MiniTest::Unit.driver.try(:quit) rescue nil
    end
    File.open("#{MiniTest::Unit.results_path}/index.html", "a") do |f|
      f.puts "</body>"
      f.puts "</html>"
    end
  rescue Exception => e
    Rails.logger.error e
  end
}

class WebDriverTestCase < ActiveSupport::TestCase
  DOWNLOAD_DIRECTORY = "/tmp/webdriver-downloads"
  
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  fixtures :all
  
  def setup
    ApplicationController.expire_cache
    driver.manage.delete_all_cookies
    File.open("#{MiniTest::Unit.results_path}/index.html", "a") do |f|
      f.puts "<p>#{self.class.name}</p>"
    end
    super
  end
  
  # Set up custom browser profile. Recreate empty downloads directory. Default webserver to localhost:3000.
  def driver
    unless MiniTest::Unit.driver
      FileUtils.rm_rf MiniTest::Unit.results_path
      FileUtils.mkdir_p MiniTest::Unit.results_path
      File.open("#{MiniTest::Unit.results_path}/index.html", "w") do |f|
        f.puts "<html>"
        f.puts "<body>"
      end
      
      FileUtils.rm_rf "#{Rails.root}/tmp/chrome-profile"
      FileUtils.mkdir_p "#{Rails.root}/tmp/chrome-profile"
      FileUtils.cp_r "#{Rails.root}/test/chrome-profile", "#{Rails.root}/tmp"

      FileUtils.rm_rf DOWNLOAD_DIRECTORY
      FileUtils.mkdir_p DOWNLOAD_DIRECTORY

      MiniTest::Unit.driver = Selenium::WebDriver.for(:chrome, :switches => ["--user-data-dir=#{Rails.root}/tmp/chrome-profile"])
    end
    MiniTest::Unit.driver
  end
  
  def open(url, expect_error_page = false)
    driver.get "http://localhost:3000" + url
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
  
  def back
    driver.navigate.back
  end
  
  def hover(element_finder)
    find_element(element_finder).hover
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
  
  def type(text, element_finder, clear = true)
    _element = find_element(element_finder)
    _element.clear if clear
    _element.send_keys text
  end
  
  # Go to login page and login
  def login_as(person_symbol)
    open "/person_session/new"
    type people(person_symbol).login, "person_session_login"
    type " ", "person_session_password", true
    type "secret", "person_session_password", true
    click "login_button"
    assert_no_errors
  end
  
  def logout
    open "/logout"
  end
  
  def select_option(value, select_element_id)
    click(:css => "select##{select_element_id} option[value='#{value}']")
  end
  
  # Workaround for WebDriver's less-than-stellar alert box handling.
  def click_ok_on_confirm_dialog
    driver.execute_script("window.confirm = function(msg){return true;};")
  end
 
  # Workaround for WebDriver's less-than-stellar alert box handling.
  def click_ok_on_alert_dialog
    driver.execute_script("window.alert = function(msg){return true;};")
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
      assert driver.current_url.include?(pattern.to_s), "Current URL #{driver.current_url} should include '#{pattern}'"
    end
  end
  
  def assert_element(element_finder)
    assert find_elements(element_finder).any?, "#{element_finder.inspect} should be present"
  end
  
  def assert_no_element(element_finder)
    assert find_elements(element_finder).empty?, "#{element_finder.inspect} should not be displayed"
  end
  
  def assert_not_displayed(element_finder)
    assert !find_element(element_finder).displayed?, "#{element_finder.inspect} should not be displayed"
  end
  
  def wait_for_element(element_finder)
    raise ArgumentError if element_finder.empty? || element_finder.blank?

    begin
      Timeout::timeout(10) do
        until find_elements(element_finder).any?
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Element #{element_finder.inspect} did not appear within 10 seconds"
    end
  end
  
  def wait_for_no_element(element_finder)
    raise ArgumentError if element_finder.empty? || element_finder.blank?

    begin
      Timeout::timeout(10) do
        until find_elements(element_finder).empty?
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Element #{element_finder.inspect} still present after 10 seconds"
    end
  end
  
  def wait_for_displayed(element_finder)
    raise ArgumentError if element_finder.empty? || element_finder.blank?

    begin
      Timeout::timeout(10) do
        until find_elements(element_finder).any? && find_elements(element_finder).first.displayed?
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Element #{element_finder.inspect} not displayed within 10 seconds"
    end
  end
  
  def wait_for_not_displayed(element_finder)
    raise ArgumentError if element_finder.empty? || element_finder.blank?

    begin
      Timeout::timeout(10) do
        until find_elements(element_finder).none? || !find_elements(element_finder).first.displayed?
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Element #{element_finder.inspect} still displayed after 10 seconds"
    end
  end
  
  def wait_for_download(glob_pattern)
    raise ArgumentError if glob_pattern.blank? || (glob_pattern.respond_to?(:empty?) && glob_pattern.empty?)
    begin
      Timeout::timeout(10) do
        while Dir.glob("#{DOWNLOAD_DIRECTORY}/#{glob_pattern}").empty?
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Did not find '#{glob_pattern}' in #{DOWNLOAD_DIRECTORY} within seconds 10 seconds. Found: #{Dir.entries(DOWNLOAD_DIRECTORY).join(", ")}"
    end
  end
  
  def wait_for_current_url(url_pattern)
    raise ArgumentError if url_pattern.blank? || (url_pattern.respond_to?(:empty?) && url_pattern.empty?)
    begin
      Timeout::timeout(10) do
        until driver.current_url.match(url_pattern)
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "URL did not become #{url_pattern} within seconds 10 seconds. Was #{driver.current_url}"
    end
  end
  
  def wait_for_not_current_url(url_pattern)
    raise ArgumentError if url_pattern.blank? || (url_pattern.respond_to?(:empty?) && url_pattern.empty?)
    Timeout::timeout(10) do
      while driver.current_url.match(url_pattern)
        sleep 0.25
      end
    end
  end
  
  def assert_value(value, element_finder)
    element = find_element(element_finder)
    case value
    when Regexp
      assert_match value, element.attribute("value")
    else
      assert_equal value.to_s, element.attribute("value")
    end
  end
  
  def wait_for_value(value, element_finder)
    raise ArgumentError if element_finder.empty? || element_finder.blank?

    begin
      Timeout::timeout(10) do
        until find_elements(element_finder).any? && case value
          when Regexp
            find_element(element_finder).attribute("value")[value]
          else
            find_element(element_finder).attribute("value")[value.to_s]
          end
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Element #{element_finder.inspect} with value '#{value}' did not appear within 10 seconds"
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

  def wait_for_text(text, element_finder)
    raise ArgumentError if element_finder.empty? || element_finder.blank?

    begin
      Timeout::timeout(10) do
        until find_elements(element_finder).any? && text.to_s == find_element(element_finder).text.to_s
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Element #{element_finder.inspect} with text '#{text}' did not appear within 10 seconds"
    end
  end
  
  def wait_for_page_source(text)
    raise ArgumentError if text.blank?

    begin
      Timeout::timeout(10) do
        until driver.page_source.include?(text)
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "'#{text}' did not appear in page source within 10 seconds"
    end
  end
  
  def assert_selected_text(text, element_finder)
    element = find_element(element_finder)
    selected_element = element.first(:css, "option[selected=selected]")
    case text
    when Regexp
      assert_match text, selected_element.text
    else
      assert_equal text.to_s, selected_element.text
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
    driver.action.drag_and_drop_by(find_element(element_finder), right_by, down_by).perform
  end
  
  def drag_and_drop_on(element_finder, on_element_finder)
    driver.action.drag_and_drop(find_element(element_finder), find_element(on_element_finder)).perform
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
  
  def remove_download(filename)
    FileUtils.rm_f "#{DOWNLOAD_DIRECTORY}/#{filename}"
  end
  
  def chrome?
    driver.try(:browser) == :chrome
  end
end
