# frozen_string_literal: true

require "test_helper"

# :stopdoc:
module Events
  class DatesTest < ActiveSupport::TestCase
    test "find years" do
      Timecop.freeze(Date.new(2012)) do
        FactoryBot.create(:event, date: Date.new(2007))
        FactoryBot.create(:event, date: Date.new(2008))
        FactoryBot.create(:event, date: Date.new(2009))
        years = Event.find_all_years
        assert_equal_enumerables [2012, 2011, 2010, 2009, 2008, 2007], years, "Should find all years with events"
      end
    end

    test "today and future" do
      past_event = FactoryBot.create(:event, date: 1.day.ago.to_date)
      today_event = FactoryBot.create(:event)
      future_event = FactoryBot.create(:event, date: 1.day.from_now.to_date)
      # Start in past but end in future
      multi_day_event = Series.create!
      multi_day_event.children.create!(date: 1.day.ago.to_date)
      multi_day_event.children.create!(date: 1.day.from_now.to_date)

      assert Event.today_and_future.include?(today_event), "today_and_future scope should include event from today"
      assert Event.today_and_future.include?(future_event), "today_and_future scope should include future event"
      assert Event.today_and_future.include?(multi_day_event), "today_and_future scope should include multi-day event that ends in future"
      assert_not Event.today_and_future.include?(past_event), "today_and_future scope should not include past event with date of #{past_event.date}"
    end

    test "set human date" do
      [
        [[2014, 5, 20], "7/25/2014",              [2014, 7, 25]],
        [[2014, 5, 20], "7-25-2014",              [2014, 7, 25]],
        [[2014, 5, 20], "7/25/14",                [2014, 7, 25]],
        [[2014, 5, 20], "7-25-14",                [2014, 7, 25]],
        [[2014, 5, 20], "Saturday, May 17, 2014", [2014, 5, 17]],
        [[2014, 5, 20], nil,                      :error],
        [[2014, 5, 20], "never!!",                :error]
      ].each do |date, human_date, expected|
        event = SingleDayEvent.new(date: Time.zone.local(*date).to_date)

        test_event = event.dup
        test_event.human_date = human_date
        assert_human_date date, human_date, expected, test_event

        # Idempotent
        test_event.human_date = human_date
        assert_human_date date, human_date, expected, test_event
      end
    end

    test "create event with human date" do
      event = SingleDayEvent.new(human_date: "June 28, 2011")
      assert_equal Time.zone.local(2011, 6, 28).to_date, event.date.to_date, "date"
    end

    test "end date" do
      event = SingleDayEvent.new(date: Date.new(2012, 4, 3))
      event.set_end_date
      assert_equal_dates Date.new(2012, 4, 3), event.end_date, "end_date"

      event.date = Date.new(2013, 1)
      assert_equal_dates Date.new(2013, 1), event.end_date, "date change should update end_date"
    end

    private

    def assert_human_date(date, human_date, expected, event)
      if expected == :error
        assert event.errors[:human_date].present?, "Should have errors for human_date: date #{date}, human_date #{human_date}"
        assert_equal Time.zone.local(*date).to_date, event.date.try(:to_date), "date. human_date: date #{date}, human_date #{human_date}"
      else
        assert_equal Time.zone.local(*expected).to_date, event.date.try(:to_date), "human_date. human_date: date #{date}, human_date #{human_date}"
      end
    end
  end
end
