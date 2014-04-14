require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  module Events
    class NewControllerTest < ActionController::TestCase
      tests EventsController

      def setup
        super
        create_administrator_session
        use_ssl
      end

      def test_new_single_day_event
        get(:new, event: { date: '2008-01-01' })
        assert_response(:success)
        assert_template('admin/events/edit')
        assert_not_nil(assigns["event"], "Should assign event")
        assert_not_nil(assigns["disciplines"], "Should assign disciplines")
        assert(assigns["event"].is_a?(Event), "Should default to SingleDayEvent")
        assert(assigns["event"].is_a?(SingleDayEvent), "Should default to SingleDayEvent")
        assert_equal 2008, assigns[:event].date.year, "Should set year"
      end

      def test_new_single_day_event_new_year
        Timecop.freeze Time.zone.local(2009, 12, 28) do
          get(:new)
          assert_response(:success)
          assert_template('admin/events/edit')
          assert_not_nil(assigns["event"], "Should assign event")
          assert_not_nil(assigns["disciplines"], "Should assign disciplines")
          assert(assigns["event"].is_a?(Event), "Should default to SingleDayEvent")
          assert(assigns["event"].is_a?(SingleDayEvent), "Should default to SingleDayEvent")
          assert_equal 2009, assigns[:event].date.year, "Should set year"
        end
      end

      def test_new_child_event
        parent = SingleDayEvent.create!
        get(:new, event: { parent_id: parent.to_param, type: "Event" })
        assert_response(:success)
        assert_template('admin/events/edit')
        assert_not_nil(assigns["event"], "Should assign event")
        assert(assigns["event"].is_a?(Event), "Should default to generic Event")
        assert(!assigns["event"].is_a?(SingleDayEvent), "Should default to generic Event")
        assert_equal(parent, assigns["event"].parent, "Parent event")
        assert_not_nil(assigns["disciplines"], "Should assign disciplines")
      end
    end
  end
end
