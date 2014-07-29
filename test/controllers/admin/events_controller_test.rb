require File.expand_path("../../../test_helper", __FILE__)

module Admin
  # :stopdoc:
  class EventsControllerTest < ActionController::TestCase

    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::CaptureHelper

    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "destroy event" do
      jack_frost = FactoryGirl.create(:event)
      delete(:destroy, id: jack_frost.to_param, commit: 'Delete')
      assert_redirected_to(admin_events_path(year: jack_frost.date.year))
      assert(!Event.exists?(jack_frost.id), "Jack Frost should have been destroyed")
    end

    test "destroy event ajax" do
      event = FactoryGirl.create(:event)
      event.destroy_races
      xhr(:delete, :destroy, id: event.to_param, commit: 'Delete')
      assert_response(:success)
      assert(!Event.exists?(event.id), "Event should have been destroyed")
    end

    test "save no promoter" do
      assert_nil(SingleDayEvent.find_by_name('Silverton'), 'Silverton should not be in database')
      # New event, no changes, single day, no promoter
      post(:create,
           "commit" => "Save",
           'same_promoter' => 'true',
           "event" => {"name" => "Silverton",
                    'type' => 'SingleDayEvent',
                    'promoter_id' => ""}
      )
      silverton = SingleDayEvent.find_by_name('Silverton')
      assert_not_nil(silverton, 'Silverton should be in database')
      assert_nil(silverton.promoter, "Silverton Promoter")
      assert_redirected_to edit_admin_event_path(assigns(:event))
    end

    test "save different promoter" do
      promoter = FactoryGirl.create(:person)
      banana_belt = FactoryGirl.create(:event, promoter: promoter)

      post(:update,
           "commit" => "Save",
           id: banana_belt.to_param,
           "event" => {"city" => "Forest Grove", "name" => "Banana Belt One","date" => "2006-03-12",
                     "flyer" => "../../flyers/2006/banana_belt.html", "sanctioned_by" => "UCI", "flyer_approved" => "1",
                     "discipline" => "Track", "cancelled" => "1", "state" => "OR", 'type' => 'SingleDayEvent',
                    "promoter_id"  => promoter.to_param}
      )
      assert_nil(flash[:warn], 'flash[:warn]')
      assert_redirected_to edit_admin_event_path(banana_belt)

      banana_belt.reload
      assert_equal(promoter, banana_belt.promoter(true), 'Promoter after save')
    end

    test "set parent" do
      event = FactoryGirl.create(:event, name: "The Event")
      assert_nil(event.parent)

      parent = FactoryGirl.create(:series, name: "The Event")
      get(:set_parent, parent_id: parent, child_id: event)

      event.reload
      assert_equal(parent, event.parent)
      assert_redirected_to edit_admin_event_path(event)
    end

    test "missing parent" do
      FactoryGirl.create(:series, name: "The Event")
      event = FactoryGirl.create(:event, name: "The Event")
      assert(event.missing_parent?, "Event should be missing parent")
      get(:edit, id: event.to_param)
      assert_response(:success)
      assert_template("admin/events/edit")
    end

    test "missing children" do
      event = FactoryGirl.create(:series, name: "The Event")
      FactoryGirl.create(:event, name: "The Event")
      assert(event.missing_children?, "Event should be missing children")
      assert_not_nil(event.missing_children, "Event should be missing children")
      get(:edit, id: event.to_param)
      assert_response(:success)
      assert_template("admin/events/edit")
    end

    test "multi day event children with no parent" do
      SingleDayEvent.create!(name: "PIR Short Track")
      SingleDayEvent.create!(name: "PIR Short Track")
      SingleDayEvent.create!(name: "PIR Short Track")
      event = SingleDayEvent.create!(name: "PIR Short Track")

      assert(event.multi_day_event_children_with_no_parent?, "multi_day_event_children_with_no_parent?")
      assert_not_nil(event.multi_day_event_children_with_no_parent, "multi_day_event_children_with_no_parent")
      assert(!(event.multi_day_event_children_with_no_parent).empty?, "multi_day_event_children_with_no_parent")
      get(:edit, id: event.to_param)
      assert_response(:success)
      assert_template("admin/events/edit")
    end

    test "add children" do
      Timecop.freeze(Time.zone.local(RacingAssociation.current.year, 10, 3)) do
        FactoryGirl.create(:event, name: "Event", date: 1.month.from_now)

        event = FactoryGirl.create(:series, name: "Event")
        get(:add_children, parent_id: event.to_param)
        assert_redirected_to edit_admin_event_path(event)
        event.reload.children(true)
        assert_equal 1.month.from_now.to_date, event.start_date, "parent start_date"
        assert_equal 1.month.from_now.to_date, event.end_date, "parent end_date"
      end
    end

    test "index" do
      get(:index, year: "2004")
      assert_response(:success)
      assert_template("admin/events/index")
      assert_not_nil(assigns["schedule"], "Should assign schedule")
    end

    test "not logged in" do
      destroy_person_session
      get(:index, year: "2004")
      assert_redirected_to new_person_session_url(secure_redirect_options)
      assert_nil(@request.session["person"], "No person in session")
    end

    test "links to years" do
      FactoryGirl.create(:event, date: Date.new(2003, 6))
      get(:index, year: "2004")

      link = @response.body["href=\"/admin/events?year=2003"]
      obra_link = @response.body["/schedule/2003"]
      assert(link || obra_link, "Should link to 2003 in:\n#{@response.body}")

      link = @response.body["href=\"/admin/events?year=2005"]
      obra_link = @response.body["/schedule/2005"]
      assert(link || obra_link, "Should link to 2005 in:\n#{@response.body}")
    end

    test "links to years only past year has events" do
      current_year = Time.zone.today.year
      last_year = current_year - 1
      SingleDayEvent.create!(date: Date.new(last_year))

      get(:index, year: current_year)
      assert_match("href=\"/admin/events?year=#{last_year}", @response.body, "Should link to #{last_year} in:\n#{@response.body}")
      assert_select(".nav a", { text: current_year.to_s }, "Should have tab for current year")
    end

    # Really only happens to developers switching environments, and more of a test of LoginSystem
    test "gracefully handle bad person id" do
      @request.session[:person_id] = 31289371283
      @request.session[:person_credentials] = 31289371283
      get(:index)
      assert_redirected_to new_person_session_url(secure_redirect_options)
    end

    test "destroy child event" do
      event = FactoryGirl.create(:series_event)
      event.destroy_races
      delete(:destroy, id: event.to_param, commit: 'Delete')
      assert(!Event.exists?(event.id), "Should have deleted Event")
    end

    test "destroy races" do
      jack_frost = FactoryGirl.create(:time_trial_event)
      jack_frost.races.create!(category: FactoryGirl.create(:category)).results.create!(place: "1", person: FactoryGirl.create(:person), time: 1200)
      CombinedTimeTrialResults.calculate!
      assert_not_nil(jack_frost.combined_results, "Event should have combined results before destroying races")
      assert_equal(1, jack_frost.races.count, "Races before destroy")
      xhr :delete, :destroy_races, id: jack_frost.id, commit: 'Delete'
      assert_not_nil(assigns(:races), "@races")
      assert_not_nil(assigns(:combined_results), "@combined_results")
      assert_response(:success)
      assert_equal(0, jack_frost.races(true).count  , "Races after destroy")
      assert_nil(jack_frost.combined_results(true), "Event should have not combined results after destroying races")
    end

    test "events for year" do
      Timecop.freeze(2005, 6) do
        single_day_event = FactoryGirl.create(:event, date: 3.days.from_now, name: "Single Day Event")
        multi_day_event_with_children = FactoryGirl.create(:stage_race, name: "Stage Race")
        multi_day_event = MultiDayEvent.create!(date: 1.week.ago, name: "Childless MultiDayEvent")

        expected_events = [ single_day_event, multi_day_event ] + multi_day_event_with_children.children
        assert_same_elements expected_events, @controller.send(:events_for_year, 2005), "events_for_year should include childless MultiDayEvents"
      end
    end
  end
end
