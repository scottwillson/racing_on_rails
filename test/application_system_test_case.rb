# frozen_string_literal: true

require "test_helper"
require_relative "system/actions"
require_relative "system/assertions"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  WebMock.disable_net_connect!(
    allow: "chromedriver.storage.googleapis.com",
    allow_localhost: true
  )

  system_test_driver = ENV["SYSTEM_TEST_DRIVER"]&.to_sym || :headless_chrome
  driven_by :selenium, using: system_test_driver, screen_size: [1400, 1400] do |driver_option|
    driver_option.add_preference(
      :download,
      default_directory: ::Assertions.download_directory
    )
  end

  Capybara.server = :puma, { Silent: true }

  include ::Actions
  include ::Assertions
end
