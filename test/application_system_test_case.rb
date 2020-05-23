# frozen_string_literal: true

require "test_helper"
require_relative "../test/elasticsearch_stubs"
require_relative "system/actions"
require_relative "system/assertions"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  WebMock.disable_net_connect!(
    allow: "chromedriver.storage.googleapis.com",
    allow_localhost: true
  )

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |driver_option|
    driver_option.add_preference(
      :download,
      default_directory: ::Assertions.download_directory
    )
  end

  Capybara.server = :puma, { Silent: true }

  setup :stub_elasticsearch
  teardown :assert_no_java_script_errors

  include ::Actions
  include ::Assertions

  def assert_no_java_script_errors
    logs = page.driver.browser.manage.logs.get(:browser)
    errors = logs.select { |log| log.level == "SEVERE" }
    return if errors.none?

    formatted_errors = errors
                       .map(&:message)
                       .map { |message| message.gsub('\\n', "\n") }
                       .join("\n\n")

    raise "Browser JavaScript errors\n\n#{formatted_errors}"
  end
end
