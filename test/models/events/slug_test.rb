require "test_helper"

# :stopdoc:
module Events
  class SlugTest < ActiveSupport::TestCase
    test "create and find events by slugs" do
      date_in_year = Time.zone.local(RacingAssociation.current.effective_year)
      old_event = SingleDayEvent.create!(slug: "banana-belt", date: 1.year.ago(date_in_year))
      event = SingleDayEvent.create!(slug: "banana-belt", date: date_in_year)

      assert_equal event, Event.find_by_slug("banana-belt")
    end

    test "newest events by slug if none for current year" do
      event = SingleDayEvent.create!(slug: "banana-belt", date: 3.years.ago)
      assert_equal event, Event.find_by_slug("banana-belt")
    end
  end
end
