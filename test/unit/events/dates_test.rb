require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
module Events
  class DatesTest < ActiveSupport::TestCase
    def test_find_years
      Timecop.freeze(Date.new(2012)) do
        FactoryGirl.create(:event, :date => Date.new(2007))
        FactoryGirl.create(:event, :date => Date.new(2008))
        FactoryGirl.create(:event, :date => Date.new(2009))
        years = Event.find_all_years
        assert_equal_enumerables [ 2012, 2011, 2010, 2009, 2008, 2007 ], years, "Should find all years with events"
      end
    end
  
    def test_today_and_future
      past_event = FactoryGirl.create(:event, :date => 1.day.ago.to_date)
      today_event = FactoryGirl.create(:event)
      future_event = FactoryGirl.create(:event, :date => 1.day.from_now.to_date)
      # Start in past but end in future
      multi_day_event = Series.create!
      multi_day_event.children.create!(:date => 1.day.ago.to_date)
      multi_day_event.children.create!(:date => 1.day.from_now.to_date)

      assert Event.today_and_future.include?(today_event), "today_and_future scope should include event from today"
      assert Event.today_and_future.include?(future_event), "today_and_future scope should include future event"
      assert Event.today_and_future.include?(multi_day_event), "today_and_future scope should include multi-day event that ends in future"
      assert !Event.today_and_future.include?(past_event), "today_and_future scope should not include past event with date of #{past_event.date}"
    end

    def test_set_human_date
      [
        [ [ 2014, 5, 20 ], "7/25/2014",              [ 2014, 7, 25 ] ],
        [ [ 2014, 5, 20 ], "7-25-2014",              [ 2014, 7, 25 ] ],
        [ [ 2014, 5, 20 ], "7/25/14",                [ 2014, 7, 25 ] ],
        [ [ 2014, 5, 20 ], "7-25-14",                [ 2014, 7, 25 ] ],
        [ [ 2014, 5, 20 ], "Saturday, May 17, 2014", [ 2014, 5, 17 ] ],
        [ [ 2014, 5, 20 ], nil,                      :error ],
        [ [ 2014, 5, 20 ], "never!!",                :error ],        
      ].each do |date, human_date, expected|
        event = SingleDayEvent.new(:date => Time.zone.local(*date).to_date)

        test_event = event.dup
        test_event.human_date = human_date
        assert_human_date date, human_date, expected, test_event

        # Idempotent
        test_event.human_date = human_date
        assert_human_date date, human_date, expected, test_event
      end
    end
  
    def test_create_event_with_human_date
      event = SingleDayEvent.new(:human_date => "June 28, 2011")
      assert_equal Time.zone.local(2011, 6, 28).to_date, event.date.to_date, "date"
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
