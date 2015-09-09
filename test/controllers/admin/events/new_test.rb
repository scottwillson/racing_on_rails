require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  module Events
    class NewControllerTest < ActionController::TestCase
      tests ::Admin::EventsController

      def setup
        super
        create_administrator_session
        use_ssl
      end

      test "new single day event" do
        get(:new, event: { date: '2008-01-01' })
        assert_response(:success)
        assert_template('admin/events/edit')
        assert_not_nil(assigns["event"], "Should assign event")
        assert_not_nil(assigns["disciplines"], "Should assign disciplines")
        assert(assigns["event"].is_a?(Event), "Should default to SingleDayEvent")
        assert(assigns["event"].is_a?(SingleDayEvent), "Should default to SingleDayEvent")
        assert_equal 2008, assigns[:event].date.year, "Should set year"
      end

      test "new single day event new year" do
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

      test "new child event" do
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
