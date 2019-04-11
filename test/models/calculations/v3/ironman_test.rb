# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::IronmanTest < ActiveSupport::TestCase
  test "#calculate!" do
    calculation = Calculations::V3::Calculation.create!(
      members_only: true
    )
    calculation.calculate!
  end
end
