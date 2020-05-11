# frozen_string_literal: true

require "test_helper"
require_relative "../test/elasticsearch_stubs"
require_relative "system/actions"
require_relative "system/assertions"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |driver_option|
    driver_option.add_preference(
      :download,
      default_directory: ::Assertions.download_directory
    )
  end

  setup :configure_webmock, :stub_elasticsearch

  include ::Actions
  include ::Assertions

  def configure_webmock
    WebMock.disable_net_connect!(
      allow: "chromedriver.storage.googleapis.com",
      allow_localhost: true
    )
  end
end
