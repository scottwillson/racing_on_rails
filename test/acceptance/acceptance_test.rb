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
# Chrome is faster (about 40%) than Firefox but requires Chromedriver binary from https://code.google.com/p/chromedriver/downloads/list
# Capybara-Webkit is very fast. Executes JS, requires Qt library, capybara-webkit gem. Several tests fail and gem is large. Not included in Gemfile.
#
# Chrome and Firefox drivers use custom profiles to ensure downloads can be tested.
class AcceptanceTest < ActiveSupport::TestCase
  DOWNLOAD_DIRECTORY = "/tmp/webdriver-downloads"
  @@profile_is_setup = false

  include Capybara::DSL

  # Selenium tests start the Rails server in a separate process. If test data is wrapped in a
  # transaction, the server won't see it.
  DatabaseCleaner.strategy = :truncation
  
  setup :clean_database, :setup_profile, :set_capybara_driver
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
    within_table(table_id) do
      within find(:xpath, "//tr[#{row}]/td[#{column}]") do
        assert page.has_content?(expected), -> { 
          "Expected '#{expected}' in row #{row} column #{column} of table #{table_id} in table ID #{table_id}, but was #{text}" 
        }
      end
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
    rescue Timeout::Error
      raise Timeout::Error, "Did not find '#{glob_pattern}' in #{DOWNLOAD_DIRECTORY} within seconds 10 seconds. Found: #{Dir.entries(DOWNLOAD_DIRECTORY).join(", ")}"
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
      press_enter "value"
    end
  end

  def press_enter(field)
    case Capybara.current_driver
    when :firefox, :chrome
      find_field(field).native.send_keys(:enter)
    when :webkit
      find_field(field).base.invoke('keypress', false, false, false, false, 13, 0);
    else
      find_field(field).native.send_keys(:enter)
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

  def clean_database
    DatabaseCleaner.clean
    Discipline.reset
  end
  
  def remove_download(filename)
    FileUtils.rm_f "#{DOWNLOAD_DIRECTORY}/#{filename}"
  end
  
  def javascript!
    Capybara.current_driver = AcceptanceTest.javascript_driver
  end
  
  def set_capybara_driver
    Capybara.current_driver = AcceptanceTest.default_driver
  end

  def setup_profile
    unless @@profile_is_setup
      FileUtils.rm_rf "#{Rails.root}/tmp/chrome-profile"
      FileUtils.mkdir_p "#{Rails.root}/tmp/chrome-profile"
      FileUtils.cp_r "#{Rails.root}/test/chrome-profile", "#{Rails.root}/tmp"

      FileUtils.rm_rf DOWNLOAD_DIRECTORY
      FileUtils.mkdir_p DOWNLOAD_DIRECTORY
      
      @@profile_is_setup = true
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
    Capybara::Selenium::Driver.new(
      app, 
      :browser => :chrome, 
      :switches => ["--user-data-dir=#{Rails.root}/tmp/chrome-profile", "--ignore-certificate-errors", "--silent"]
    )
  end
  
  Capybara.register_driver :firefox do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.folderList']            = 2
    profile['browser.download.dir']                   = DOWNLOAD_DIRECTORY
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
