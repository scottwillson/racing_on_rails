require "test_helper"

# :stopdoc:
module Events
  class SlugTest < ActiveSupport::TestCase
    test "create and find events by slugs" do
      date_in_year = Time.zone.local(RacingAssociation.current.effective_year)
      old_event = SingleDayEvent.create!(name: "Banana Belt", date: 1.year.ago(date_in_year))
      event = SingleDayEvent.create!(name: "Banana Belt", date: date_in_year)

      assert_equal event, Event.find_by_slug("banana_belt")
    end

    test "newest events by slug if none for current year" do
      event = SingleDayEvent.create!(name: "Banana Belt", date: 3.years.ago)
      assert_equal event, Event.find_by_slug("banana_belt")
    end

    test "create_slug" do
      event = Event.new(name: "OBRA TT")
      assert_equal "obra_tt", event.create_slug

      event = Event.new(name: "2013 Oregon Cup")
      assert_equal "oregon_cup", event.create_slug

      event = Event.new(name: "Cross Crusade: Overall")
      assert_equal "cross_crusade_overall", event.create_slug
    end
  end
end
