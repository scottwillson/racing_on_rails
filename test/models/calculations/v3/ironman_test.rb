# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::IronmanTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "#calculate!" do
    past_member = FactoryBot.create(:past_member)
    FactoryBot.create(:result, person: past_member)

    FactoryBot.create(:result, place: 40)

    calculation = Calculations::V3::Calculation.create!(
      members_only: true,
      name: "Ironman",
      points_for_place: 1
    )
    calculation.calculate!

    assert_equal "Ironman", calculation.reload.event.name
    assert_equal 1, calculation.event.races.size
    race = calculation.event.races.first
    assert_equal 2, race.results.size

    results = race.results.sort
    result = results.first
    assert_equal "1", result.place
    assert_equal 1, result.points
    refute result.rejected?
    assert_equal 1, result.sources.size
    source = result.sources.first!
    assert_equal 1, source.points
    refute source.rejected?

    result = results[1]
    assert_equal "", result.place
    assert_equal 0, result.points
    assert_equal "members_only", result.rejection_reason
  end
end
