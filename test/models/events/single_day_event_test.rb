require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class SingleDayEventTest < ActiveSupport::TestCase
  test "full name" do
    kings_valley = FactoryGirl.build(:event, name: "Kings Valley Road Race")
    assert_equal('Kings Valley Road Race', kings_valley.full_name, 'Event with no parent full_name')

    stage = FactoryGirl.create(:stage_race, name: "Mt. Hood Classic").children.first
    stage.update_attributes(name: "Mount Hood Day 1")
    assert_equal('Mt. Hood Classic: Mount Hood Day 1', stage.full_name, 'stage full_name')

    stage.update_attributes(name: "Mt. Hood Classic")
    assert_equal('Mt. Hood Classic', stage.full_name, 'stage full_name')

    stage.update_attributes(name: "Mt. Hood Classic Stage One")
    assert_equal('Mt. Hood Classic Stage One', stage.full_name, 'stage full_name')
  end
end
