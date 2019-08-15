# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::IronmanTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "#calculate!" do
    calculation = Calculations::V3::Calculation.create!(
      members_only: true,
      name: "Ironman",
      points_for_place: 1
    )
    calculation.calculate!

    assert_equal "Ironman", calculation.reload.event.name
  end
end
