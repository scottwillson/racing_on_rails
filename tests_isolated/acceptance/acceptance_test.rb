# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "../../config/environment"
require "capybara/rails"
require "minitest/autorun"
require "webmock/minitest"
require "capybara-screenshot/minitest"
require_relative "../../test/elasticsearch_stubs"

# Capybara supports a number of drivers/browsers. AcceptanceTest default is RackTest for non-JavaScript tests
# and Chrome for JS test. Note that most tests require JS.
#
# Use DEFAULT_DRIVER and JAVASCRIPT_DRIVER to set Capybara drivers:
# :rack_test, :firefox, :selenium_chrome_headless, :poltergeist, :webkit
#
# RackTest is fastest *about 20% faster than Chrome) and has no dependencies, but does not execute JS.
# Firefox via Selenium is slowest option. It executes JS, has no dependencies and is the most reliable. Uses a custom profile to
# test downloads.
# Chrome is faster (about 9%) than Firefox but requires Chromedriver binary from https://code.google.com/p/chromedriver/downloads/list.
# Capybara-Webkit is the fastest (about 50% faster than Firefox). Executes JS, requires Qt library, capybara-webkit gem.
# Need to fake downloads and tends to be less stable. Not included by default. Need 'require "capybara/webkit"' in AcceptanceTest
# and a custom Gemfile with 'gem "capybara-webkit"'.
class AcceptanceTest < ActiveSupport::TestCase
  include Capybara::DSL
  include Capybara::Screenshot::MiniTestPlugin
  include ElasticsearchStubs

  # Selenium tests start the Rails server in a separate process. If test data is wrapped in a
  # transaction, the server won't see it.
  DatabaseCleaner.strategy = :truncation, { except: %w[ar_internal_metadata] }

  Webdrivers.cache_time = 86_400
  Capybara.asset_host = "http://0.0.0.0:3000"
  Capybara::Screenshot.prune_strategy = :keep_last_run

  setup :clean_database, :set_capybara_driver, :configure_webmock, :stub_elasticsearch
  teardown :report_javascript_errors, :reset_session

  def self.javascript_driver
    if ENV["JAVASCRIPT_DRIVER"].present?
      ENV["JAVASCRIPT_DRIVER"].to_sym
    else
      :selenium_chrome_headless
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
    "/tmp/webdriver-downloads"
  end

  def configure_webmock
    WebMock.disable_net_connect!(
      allow: "chromedriver.storage.googleapis.com",
      allow_localhost: true
    )
  end

  def assert_page_has_content(text)
    raise "Expected '#{text}' in page source" unless page.has_content?(text)
  end

  def assert_page_has_no_content(text)
    raise "Did not expect '#{text}' in html" unless page.has_no_content?(text)
  end

  def assert_table(table_id, row, column, expected)
    assert page.has_table?(table_id), "Expected table with id '#{table_id}'"
    within find(:xpath, "//table[@id='#{table_id}']//tr[#{row}]/td[#{column}]") do
      assert page.has_content?(expected), -> {
        "Expected '#{expected}' in row #{row} column #{column} of table #{table_id} in table ID #{table_id}, but was #{text}"
      }
    end
  end

  def assert_download(link_id, filename)
    raise ArgumentError if filename.blank? || (filename.respond_to?(:empty?) && filename.empty?)

    make_download_directory
    remove_download filename

    if Capybara.current_driver == :poltergeist || Capybara.current_driver == :webkit
      assert_download_via_ajax link_id, filename
    else
      wait_for_download_in_download_directory link_id, filename
    end
  end

  def assert_download_via_ajax(link_id, filename)
    href = find("##{link_id}")["href"]
    downloadCSVXHR = "
      window.downloadCSVXHR = function() {
        var url = '#{href}';
        return getFile(url);
      }

      window.getFile = function(url) {
        var responseData;
        var x = jQuery.ajax({
          url: url,
          async: false,
          success: function(data, textStatus) {
            responseData = data;
          }
        });
        return responseData;
      }"
    page.execute_script downloadCSVXHR
    data = page.evaluate_script("downloadCSVXHR()")
    assert data.present?, "Download for #{filename} at #{href} from #{link_id} empty"
  end

  def wait_for_download_in_download_directory(link_id, filename)
    click_on link_id
    begin
      Timeout.timeout(10) do
        sleep 0.25 while Dir.glob("#{AcceptanceTest.download_directory}/#{filename}").empty?
      end
    rescue Timeout::Error
      raise Timeout::Error, "Did not find '#{filename}' in #{AcceptanceTest.download_directory} within seconds 10 seconds. Found: #{Dir.entries(AcceptanceTest.download_directory).join(', ')}"
    end
  end

  def wait_for_page_content(text)
    raise ArgumentError if text.blank?

    begin
      Timeout.timeout(10) do
        sleep 0.25 until page.has_content?(text)
      end
    rescue Timeout::Error
      raise "'#{text}' did not appear in page source within 10 seconds"
    end
  end

  def wait_for_page_no_content(text)
    raise ArgumentError if text.blank?

    begin
      Timeout.timeout(10) do
        sleep 0.25 while page.has_content?(text)
      end
    rescue Timeout::Error
      raise "'#{text}' in page source after 10 seconds"
    end
  end

  def wait_for_select(id, options)
    raise ArgumentError if id.blank?

    begin
      Timeout.timeout(10) do
        sleep 0.25 until page.has_select?(id, selected: options[:selected])
      end
    rescue Timeout::Error
      raise Timeout::Error, "'#{options[:selected]}' not selected on #{id} within 10 seconds"
    end
  end

  def wait_for(*locator)
    raise ArgumentError if locator.blank?

    begin
      Timeout.timeout(10) do
        sleep 0.25 until page.has_selector?(*locator)
      end
    rescue Timeout::Error
      raise "'#{locator}' did not appear within 10 seconds"
    end
  end

  def wait_for_no(*locator)
    raise ArgumentError if locator.blank?

    begin
      Timeout.timeout(10) do
        sleep 0.25 while page.has_selector?(*locator)
      end
    rescue Timeout::Error
      raise "'#{locator}' still present after 10 seconds"
    end
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script("jQuery.active").zero?
  end

  # Helpful for clicking links that are bound to JS handlers. Need to click after handler is bound.
  def click_until(link_css, &block)
    raise ArgumentError if link_css.blank? || block.nil?

    begin
      Timeout.timeout(10) do
        until yield
          find(link_css).click
          sleep 0.1
        end
      end
    rescue Timeout::Error
      raise "'#{link_css}' did not appear in page source within 10 seconds"
    end
  end

  def fill_in_inline(locator, options)
    assert_edit = options.delete(:assert_edit)
    text = options[:with]
    options[:with] = options[:with] + "\n"
    wait_for locator
    find(locator).click
    fill_in_editor_field options
    wait_for_no ".editing"
    wait_for_no ".saving"
    if assert_edit
      within locator do
        assert page.has_content?(text)
      end
    end
  end

  def fill_in_editor_field(options)
    retries = 0
    3.times do
      wait_for "form.editor_field"
      within "form.editor_field" do
        wait_for "input[name='value']"
        fill_in "value", options
      end
      return true
    rescue Capybara::ElementNotFound, RuntimeError, Capybara::Poltergeist::ObsoleteNode
      if retries < 3
        retries = + 1
        sleep 0.1
        retry
      else
        raise "#{Regexp.last_match(1)} for fill_in_editor_field(#{options}) after #{retries} tries"
      end
    end
  end

  def fill_in(locator, options)
    if Capybara.current_driver == :poltergeist &&
       options[:with] &&
       options[:with]["\n"]

      options[:with] = options[:with].delete("\n")
      super locator, options
      press_return locator
    else
      super locator, options
    end
  end

  def press_return(field)
    press :return, field
  end

  def press(key, field)
    errors = 0
    begin
      press_once key, field
    rescue StandardError
      errors += 1
      retry if errors < 4
    end
  end

  def press_once(key, field)
    if Capybara.current_driver == :poltergeist
      case key
      when :down
        find_field(field).native.send_keys(:Down)
      when :enter, :return
        find_field(field).native.send_keys(:Enter)
      when :tab
        find_field(field).native.send_keys(:Tab)
      else
        find_field(field).native.send_keys(key)
      end
    elsif Capybara.current_driver == :webkit
      keypress_script = "var e = $.Event('keypress', { keyCode: #{key_code(key)} }); $('##{field}').trigger(e);"
      page.driver.browser.execute_script(keypress_script)
    else
      find_field(field).native.send_keys(key)
    end
  end

  def key_code(key)
    case key
    when :down
      40
    when :enter
      13
    when :return
      10
    when :tab
      9
    else
      key.ord
    end
  end

  # keypress: function(index, altKey, ctrlKey, shiftKey, metaKey, keyCode, charCode) {
  def type_in(selector, text)
    if selector["autocomplete"]
      fill_in selector, with: ""
      find("##{selector}").native.send_keys(text[:with])
    else
      fill_in selector, text
    end
  end

  def click_ok_on_alert_dialog
    page.evaluate_script "window.alert = function(msg){return true;};"
  end

  def click_ok_on_confirm_dialog
    page.evaluate_script "window.confirm = function(msg){return true;};"
  end

  def create_new_login
    fill_in "person_login", with: "kc@iq-9.com"
    fill_in "person_password", with: "condor"
    fill_in "person_name", with: "Kevin Condron"
    fill_in "person_license", with: "576"
    fill_in "person_email", with: "kc@iq-9.com"
    click_button "Save"
  end

  def assert_login_page
    assert_current_path "/person_session/new"
  end

  # Go to login page and login
  def login_as(person)
    visit "/person_session/new" unless current_path == "/person_session/new"
    wait_for "#person_session_login"
    fill_in "person_session_login", with: person.login
    fill_in "person_session_password", with: "secret"
    click_button "login_button"
  end

  def logout
    visit "/logout"
  end

  def visit_event(event)
    click_link event.name
  end

  def clean_database
    DatabaseCleaner.clean
    Discipline.reset
  end

  def make_download_directory
    FileUtils.mkdir_p AcceptanceTest.download_directory unless Dir.exist?(AcceptanceTest.download_directory)
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

  def reset_session
    Capybara.reset_sessions!
  rescue StandardError => e
    Rails.logger.debug "Timeout resetting Capybara session: #{e}."
  end

  def before_teardown
    unless passed?
      begin
        save_page
      rescue StandardError => e
        Rails.logger.error "Test did not pass. Could not save page: #{e}."
      end
    end
  end

  def say_if_verbose(text)
    puts text if ENV["VERBOSE"].present?
  end

  def report_javascript_errors
    return unless Capybara.current_driver == :selenium_chrome_headless

    errors = page.driver.browser.manage.logs.get(:browser)
    errors.each do |error|
      if error.level == 'WARNING'
        STDERR.puts 'WARN: javascript warning'
        STDERR.puts error.message
        next
      end
      raise error.message
    end
  end

  def select_existing_event(field, name, search_for = nil)
    select_existing("event", field, name, search_for)
  end

  def select_new_event(field, name)
    select_new("event", field, name)
  end

  def select_existing_person(field, name, search_for = nil)
    select_existing("person", field, name, search_for)
  end

  def select_new_person(field, name)
    select_new("person", field, name)
  end

  def select_existing_team(field, name, search_for = nil)
    select_existing("team", field, name, search_for)
  end

  def select_new_team(field, name)
    select_new("team", field, name)
  end

  def select_existing(type, field, name, search_for)
    search_for ||= name
    click_button "#{field}_select_modal_button"
    wait_for ".modal.in"
    fill_in "name", with: search_for

    find("tr[data-#{type}-name=\"#{name}\"]").click
    assert_equal name, find("##{field}_name", visible: false).value
    assert_equal name, find("##{field}_select_modal_button").text
  end

  def select_new(type, field, name)
    click_button "#{field}_select_modal_button"
    wait_for ".modal.in"
    find("#show_#{field}_new_modal").click
    wait_for "##{field}_select_modal_new_#{type}"
    wait_for "##{field}_new_#{type}_name"
    fill_in "#{field}_new_#{type}_name", with: name
    find_field("#{field}_new_#{type}_name", wait: 4, with: name)
    find("##{field}_select_modal_new_#{type}_create").click
  end

  Capybara.register_driver :selenium_chrome_headless do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument "--headless"
    options.add_argument "--no-sandbox"
    options.add_argument "--disable-gpu"
    options.add_argument "--disable-popup-blocking"
    options.add_argument "--window-size=1024,768"

    options.add_preference(
      :download,
      directory_upgrade: true,
      prompt_for_download: false,
      default_directory: AcceptanceTest.download_directory
    )

    options.add_preference(:browser, set_download_behavior: { behavior: "allow" })

    driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)

    bridge = driver.browser.send(:bridge)
    path = "/session/#{bridge.session_id}/chromium/send_command"

    bridge.http.call(:post, path, cmd: "Page.setDownloadBehavior",
                                  params: {
                                    behavior: "allow",
                                    downloadPath: AcceptanceTest.download_directory
                                  })

    driver
  end

  Capybara.register_driver :firefox do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile["browser.download.folderList"]            = 2
    profile["browser.download.dir"]                   = AcceptanceTest.download_directory
    profile["browser.helperApps.neverAsk.saveToDisk"] = "application/vnd.ms-excel,application/vnd.ms-excel; charset=utf-8"

    Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
  end

  Capybara::Screenshot.register_driver(:selenium_chrome_headless) do |driver, path|
    driver.browser.save_screenshot(path)
  end

  Capybara::Screenshot.register_driver(:firefox) do |driver, path|
    driver.browser.save_screenshot(path)
  end

  Capybara.current_driver = default_driver
  Capybara.javascript_driver = javascript_driver
end
