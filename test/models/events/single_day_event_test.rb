# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

# :stopdoc:
class SingleDayEventTest < ActiveSupport::TestCase
  test "full name" do
    kings_valley = FactoryBot.build(:event, name: "Kings Valley Road Race")
    assert_equal("Kings Valley Road Race", kings_valley.full_name, "Event with no parent full_name")

    stage = FactoryBot.create(:stage_race, name: "Mt. Hood Classic").children.first
    stage.update(name: "Mount Hood Day 1")
    assert_equal("Mt. Hood Classic: Mount Hood Day 1", stage.full_name, "stage full_name")

    stage.update(name: "Mt. Hood Classic")
    assert_equal("Mt. Hood Classic", stage.full_name, "stage full_name")

    stage.update(name: "Mt. Hood Classic Stage One")
    assert_equal("Mt. Hood Classic Stage One", stage.full_name, "stage full_name")
  end
end
