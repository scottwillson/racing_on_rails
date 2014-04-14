require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  module Events
    class EditControllerTest < ActionController::TestCase
      tests Admin::EventsController

      def setup
        super
        create_administrator_session
        use_ssl
      end

      test "edit" do
        event = FactoryGirl.create(:event, velodrome: FactoryGirl.create(:velodrome))
        get(:edit, id: event.to_param)
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
        assert(!@response.body["#&lt;Velodrome:"], "Should not have model in text field")
        assert_select "input#event_human_date"
      end

      test "edit sti subclasses" do
        [SingleDayEvent, MultiDayEvent, Series, WeeklySeries].each do |event_class|
          event = event_class.create!
          get(:edit, id: event.to_param)
          assert_response(:success)
          if event_class == SingleDayEvent
            assert_select "input#event_human_date"
          else
            assert_select "input#event_human_date", count: 0
          end
        end
      end

      test "edit parent" do
        event = FactoryGirl.create(:series)
        get(:edit, id: event.to_param)
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
      end

      test "edit no results" do
        event = FactoryGirl.create(:event)
        get(:edit, id: event.to_param)
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
      end

      test "edit with promoter" do
        event = FactoryGirl.create(:event)
        get(:edit, id: event.to_param)
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
      end

      test "edit as promoter" do
        event = FactoryGirl.create(:event)
        login_as event.promoter
        get :edit, id: event.to_param
        assert_response :success
        assert_template "admin/events/edit"
        assert_select "#event_human_date", count: 0
      end

      test "promoter can only edit own events" do
        event = FactoryGirl.create(:event)
        event_2 = FactoryGirl.create(:event)

        login_as event_2.promoter
        get :edit, id: event.to_param
        assert_redirected_to unauthorized_path
      end

      test "edit as editor" do
        event = FactoryGirl.create(:event)
        person = FactoryGirl.create(:person)
        event.editors << person
        login_as person
        get :edit, id: event.to_param
        assert_response :success
        assert_template "admin/events/edit"
        assert_select "#event_human_date", count: 0
      end

      test "edit child event" do
        event = FactoryGirl.create(:series_event)
        get(:edit, id: event.id)
        assert_response(:success)
      end

      test "edit combined results" do
        event = FactoryGirl.create(:time_trial_event)
        FactoryGirl.create(:result, event: event)
        combined = CombinedTimeTrialResults.create!(parent: event)
        get(:edit, id: combined.id)
        assert_response(:success)
      end
    end
  end
end
