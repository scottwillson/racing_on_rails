require "test_helper"

# :stopdoc:
class RacesCollectionTest < ActiveSupport::TestCase
  test "new" do
    RacesCollection.new(Event.new)
  end

  test "size" do
    event = Event.new
    assert_equal 0, RacesCollection.new(event).size

    event.races.build
    assert_equal 1, RacesCollection.new(event).size
  end

  test "text when blank" do
    assert_equal "", RacesCollection.new(Event.new).text
  end

  test "text" do
    event = Event.new
    event.races.build category: Category.new(name: "Senior Men")
    event.races.build category: Category.new(name: "Men A")
    assert_equal "Men A\nSenior Men", RacesCollection.new(event).text
  end

  test "update blank no races" do
    event = FactoryGirl.create(:event)

    races_collection = RacesCollection.new(event)
    races_collection.update text: ""

    event.races true
    assert_equal "", races_collection.text
  end

  test "update add races" do
    event = FactoryGirl.create(:event)

    races_collection = RacesCollection.new(event)
    races_collection.update text: "\r\nMen A\r\n\r\nMen B\r\n\r\n"

    event.races true
    assert_equal "Men A\nMen B", races_collection.text
  end

  test "update remove races" do
    event = FactoryGirl.create(:event)
    event.races.create! category: Category.new(name: "Men A")
    event.races.create! category: Category.new(name: "Beginners")

    races_collection = RacesCollection.new(event)
    races_collection.update text: "Men A\r\nMen B"

    event.races true
    assert_equal "Men A\nMen B", races_collection.text
  end

  test "persisted?" do
    assert RacesCollection.new(Event.new).persisted?
  end
end
