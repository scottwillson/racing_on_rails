# frozen_string_literal: true

require File.expand_path("../../../test_helper", __dir__)

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
        event = FactoryBot.create(:event, velodrome: FactoryBot.create(:velodrome))
        get :edit, params: { id: event.to_param }
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
        assert_not(@response.body["#&lt;Velodrome:"], "Should not have model in text field")
        assert_select "input#event_human_date"
      end

      test "edit sti subclasses" do
        [SingleDayEvent, MultiDayEvent, Series, WeeklySeries].each do |event_class|
          event = event_class.create!
          get :edit, params: { id: event.to_param }
          assert_response(:success)
          if event_class == SingleDayEvent
            assert_select "input#event_human_date"
          else
            assert_select "input#event_human_date", count: 0
          end
        end
      end

      test "edit parent" do
        event = FactoryBot.create(:series)
        get :edit, params: { id: event.to_param }
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
      end

      test "edit no results" do
        event = FactoryBot.create(:event)
        get :edit, params: { id: event.to_param }
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
      end

      test "edit with promoter" do
        event = FactoryBot.create(:event)
        get :edit, params: { id: event.to_param }
        assert_response(:success)
        assert_template("admin/events/edit")
        assert_not_nil(assigns["event"], "Should assign event")
        assert_nil(assigns["race"], "Should not assign race")
      end

      test "edit as promoter" do
        event = FactoryBot.create(:event)
        login_as event.promoter
        get :edit, params: { id: event.to_param }
        assert_response :success
        assert_template "admin/events/edit"
        assert_select "#event_human_date", count: 0
      end

      test "promoter can only edit own events" do
        event = FactoryBot.create(:event)
        event_2 = FactoryBot.create(:event)

        login_as event_2.promoter
        get :edit, params: { id: event.to_param }
        assert_redirected_to unauthorized_path
      end

      test "edit as editor" do
        event = FactoryBot.create(:event)
        person = FactoryBot.create(:person)
        event.editors << person
        login_as person
        get :edit, params: { id: event.to_param }
        assert_response :success
        assert_template "admin/events/edit"
        assert_select "#event_human_date", count: 0
      end

      test "edit child event" do
        event = FactoryBot.create(:series_event)
        get :edit, params: { id: event.id }
        assert_response(:success)
      end
    end
  end
end
