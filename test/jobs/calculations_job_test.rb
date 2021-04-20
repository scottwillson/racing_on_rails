# frozen_string_literal: true

require "test_helper"

class CalculationsJobTest < ActiveJob::TestCase
  test "perfom" do
    CalculationsJob.perform_now
  end
end
