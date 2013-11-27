ENV["RAILS_ENV"] = "acceptance"

require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
require "capybara/rails"
require "minitest/autorun"
 
# Capybara supports a number of drivers/browsers. AcceptanceTest default is RackTest for non-JavaScript tests
# and Firefox for JS test. Note that most tests require JS.
#
# Use DEFAULT_DRIVER and JAVASCRIPT_DRIVER to set Capybara drivers:
# :rack_test, :firefox, :chrome, :webkit
#
# RackTest is fastest *about 20% faster than Chrome) and has no dependencies, but does not execute JS.
# Firefox is slowest option. Executes JS, has no dependencies and tests pass.
# Chrome is faster (about 40%) than Firefox but requires Chromedriver binary from https://code.google.com/p/chromedriver/downloads/list.
# Occasionally hangs, and current version can't set download directory.
# Capybara-Webkit is very fast. Executes JS, requires Qt library, capybara-webkit gem. Several tests fail and gem is large. Not included.
#
# Firefox driver uses a custom profile to test downloads.
class AcceptanceTest < ActiveSupport::TestCase
  include Capybara::DSL

  # Selenium tests start the Rails server in a separate process. If test data is wrapped in a
  # transaction, the server won't see it.
  DatabaseCleaner.strategy = :truncation
  
  setup :clean_database, :clear_downloads, :set_capybara_driver
  teardown :reset_session
  
  def self.javascript_driver
    if ENV["JAVASCRIPT_DRIVER"].present?
      ENV["JAVASCRIPT_DRIVER"].to_sym
    else
      :firefox
    end
  end
  
  def self.default_driver
    if ENV["DEFAULT_DRIVER"].present?
      ENV["DEFAULT_DRIVER"].to_sym
    else
      :rack_test
    end
  end
  
  def self.download_directory
    if AcceptanceTest.javascript_driver == :chrome
      File.expand_path "~/Downloads"
    else
      "/tmp/webdriver-downloads"
    end
  end
  
  def assert_page_has_content(text)
    unless page.has_content?(text)
      fail "Expected '#{text}' in page source"
    end
  end
  
  def assert_page_has_no_content(text)
    unless page.has_no_content?(text)
      fail "Did not expect '#{text}' in html"
    end
  end
  
  def assert_table(table_id, row, column, expected)
    assert page.has_table?(table_id), "Expected table with id '#{table_id}'"
    within find(:xpath, "//table[@id='#{table_id}']//tr[#{row}]/td[#{column}]") do
      assert page.has_content?(expected), -> { 
        "Expected '#{expected}' in row #{row} column #{column} of table #{table_id} in table ID #{table_id}, but was #{text}" 
      }
    end
  end

  def wait_for_download(glob_pattern)
    raise ArgumentError if glob_pattern.blank? || (glob_pattern.respond_to?(:empty?) && glob_pattern.empty?)
    begin
      Timeout::timeout(10) do
        while Dir.glob("#{AcceptanceTest.download_directory}/#{glob_pattern}").empty?
          sleep 0.25
        end
      end
    rescue Timeout::Error
      raise Timeout::Error, "Did not find '#{glob_pattern}' in #{AcceptanceTest.download_directory} within seconds 10 seconds. Found: #{Dir.entries(AcceptanceTest.download_directory).join(", ")}"
    end
  end

  def wait_for_page_content(text)
    raise ArgumentError if text.blank?

    begin
      Timeout::timeout(10) do
        until page.has_content?(text)
          sleep 0.25
        end
      end
    rescue Timeout::Error
      fail "'#{text}' did not appear in page source within 10 seconds"
    end
  end

  def wait_for_page_no_content(text)
    raise ArgumentError if text.blank?

    begin
      Timeout::timeout(10) do
        while page.has_content?(text)
          sleep 0.25
        end
      end
    rescue Timeout::Error
      fail "'#{text}' in page source after 10 seconds"
    end
  end
  
  def wait_for_select(id, options)
    raise ArgumentError if id.blank?

    begin
      Timeout::timeout(10) do
        until page.has_select?(id, :selected => options[:selected])
          sleep 0.25
        end
      end
    rescue Timeout::Error
      raise Timeout::Error, "'#{options[:selected]}' not selected on #{id} within 10 seconds"
    end
  end

  def wait_for(locator)
    raise ArgumentError if locator.blank?

    begin
      Timeout::timeout(10) do
        until page.has_selector?(locator)
          sleep 0.25
        end
      end
    rescue Timeout::Error
      fail "'#{locator}' did not appear in page source within 10 seconds"
    end
  end

  # Helpful for clicking links that are bound to JS handlers. Need to click after handler is bound.
  def click_until(link_css, &block)
    raise ArgumentError if link_css.blank? || block.nil?

    begin
      Timeout::timeout(10) do
        until block.call
          find(link_css).click
          sleep 0.1
        end
      end
    rescue Timeout::Error
      fail "'#{text}' did not appear in page source within 10 seconds"
    end
  end

  def fill_in_inline(locator, options)
    find(locator).click
    within "form.editor_field" do
      fill_in "value", options
      press_return "value"
    end
  end

  def press_return(field)
    press :return, field
  end

  def press(key, field)
    case Capybara.current_driver
    when :firefox, :chrome
      find_field(field).native.send_keys(key)
    when :webkit
      find_field(field).base.invoke('keypress', false, false, false, false, key_code(key), 0)
    else
      find_field(field).native.send_keys(key)
    end
  end
  
  def key_code(key)
    case key
    when :enter
      13
    when :return
      10
    when :tab
      9
    else
      raise "No code for #{key}"
    end
  end
  
  def click_ok_on_alert_dialog
    page.evaluate_script "window.alert = function(msg){return true;};"
  end

  def click_ok_on_confirm_dialog
    page.evaluate_script "window.confirm = function(msg){return true;};"
  end

  # Go to login page and login
  def login_as(person)
    visit "/person_session/new"
    wait_for "#person_session_login"
    fill_in "person_session_login", :with => person.login
    fill_in "person_session_password", :with => "secret"
    click_button "login_button"
  end
  
  def logout
    visit "/logout"
  end

  # Work around Chrome bug
  def visit_event(event)
    if Capybara.current_driver == :chrome
      visit "/admin/events/#{event.id}/edit"
    else
      click_link event.name
    end
  end

  def clean_database
    DatabaseCleaner.clean
    Discipline.reset
  end
  
  def remove_download(filename)
    FileUtils.rm_f "#{AcceptanceTest.download_directory}/#{filename}"
  end
  
  def javascript!
    Capybara.current_driver = AcceptanceTest.javascript_driver
  end
  
  def set_capybara_driver
    Capybara.current_driver = AcceptanceTest.default_driver
  end

  def clear_downloads
    unless AcceptanceTest.javascript_driver == :chrome
      if Dir.exists?(AcceptanceTest.download_directory)
        FileUtils.rm_rf AcceptanceTest.download_directory
      end
    end

    unless Dir.exists?(AcceptanceTest.download_directory)
      FileUtils.mkdir_p AcceptanceTest.download_directory
    end
  end
  
  def reset_session
    Capybara.reset_sessions!
  end
  
  def before_teardown
    unless @passed
      save_page
    end
  end

  def say_if_verbose(text)
    if ENV["VERBOSE"].present?
      puts text
    end
  end
  
  Capybara.register_driver :chrome do |app|
    if Dir.exists?("#{Rails.root}/tmp/chrome-profile")
      FileUtils.rm_rf "#{Rails.root}/tmp/chrome-profile"
    end
    
    unless Dir.exists?("#{Rails.root}/tmp/chrome-profile")
      FileUtils.mkdir "#{Rails.root}/tmp/chrome-profile"
    end

    Capybara::Selenium::Driver.new(
      app, 
      :browser => :chrome, 
      :switches => ["--user-data-dir=#{Rails.root}/tmp/chrome-profile", "--ignore-certificate-errors", "--silent"]
    )
  end

  Capybara.register_driver :firefox do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.folderList']            = 2
    profile['browser.download.dir']                   = AcceptanceTest.download_directory
    profile['browser.helperApps.neverAsk.saveToDisk'] = "application/vnd.ms-excel,application/vnd.ms-excel; charset=utf-8"

    Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile) 
  end

  Capybara.configure do |config|
    config.current_driver = default_driver
    config.javascript_driver = javascript_driver

    if RacingAssociation.current.ssl?
      config.app_host       = "http://localhost"
      config.server_port    = 8080
    end
  end
end
