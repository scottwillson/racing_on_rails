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

      def test_edit
        event = FactoryGirl.create(:event, velodrome: FactoryGirl.create(:velodrome))
        get(:edit, id: event.to_param)
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
        assert(!@response.body["#&lt;Velodrome:"], "Should not have model in text field")
        assert_select "input#event_human_date"
      end

      def test_edit_sti_subclasses
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

      def test_edit_parent
        event = FactoryGirl.create(:series)
        get(:edit, id: event.to_param)
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
      end

      def test_edit_no_results
        event = FactoryGirl.create(:event)
        get(:edit, id: event.to_param)
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
      end

      def test_edit_with_promoter
        event = FactoryGirl.create(:event)
        get(:edit, id: event.to_param)
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
      end

      def test_edit_as_promoter
        event = FactoryGirl.create(:event)
        login_as event.promoter
        get :edit, id: event.to_param
        assert_response :success
        assert_template "admin/events/edit"
        assert_select "#event_human_date", count: 0
      end

      def test_promoter_can_only_edit_own_events
        event = FactoryGirl.create(:event)
        event_2 = FactoryGirl.create(:event)

        login_as event_2.promoter
        get :edit, id: event.to_param
        assert_redirected_to unauthorized_path
      end

      def test_edit_as_editor
        event = FactoryGirl.create(:event)
        person = FactoryGirl.create(:person)
        event.editors << person
        login_as person
        get :edit, id: event.to_param
        assert_response :success
        assert_template "admin/events/edit"
        assert_select "#event_human_date", count: 0
      end

      def test_edit_child_event
        event = FactoryGirl.create(:series_event)
        get(:edit, id: event.id)
        assert_response(:success)
      end

      def test_edit_combined_results
        event = FactoryGirl.create(:time_trial_event)
        FactoryGirl.create(:result, event: event)
        combined = CombinedTimeTrialResults.create!(parent: event)
        get(:edit, id: combined.id)
        assert_response(:success)
      end
    end
  end
end
