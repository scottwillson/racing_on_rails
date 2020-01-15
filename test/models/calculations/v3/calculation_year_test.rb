# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::YearTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "create!" do
    calculation = Calculations::V3::Calculation.create!(
      key: :oregon_cup,
      members_only: true,
      points_for_place: [100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10],
      specific_events: true,
      year: 2017
    )
    pro_1_2_men = ::Category.find_or_create_by(name: "Pro/1/2 Men")
    calculation.categories << pro_1_2_men

    Timecop.freeze(2020, 1, 15) do
      Calculations::V3::Year.create!(key: :oregon_cup)
    end

    calculation = Calculations::V3::Calculation.find_by!(key: :oregon_cup, year: 2020)

    assert calculation.members_only?
    assert_equal "category", calculation.group_by
    assert_equal [pro_1_2_men], calculation.categories
  end

  # TODO: already exists
  # TODO: Find similar source_event_id
  # Add source event later update?
  # Also events
end
