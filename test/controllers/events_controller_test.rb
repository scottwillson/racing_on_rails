# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class EventsControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_redirected_to schedule_path
  end

  test "index with person id" do
    promoter = FactoryBot.create(:promoter)
    get :index, params: { person_id: promoter }
    assert_response :success
    assert_select ".nav.tabs", count: 0
    assert_select "a[href*='/admin/events']", 0
  end

  test "index with person id promoter" do
    Timecop.freeze(Time.zone.local(2012)) do
      promoter = FactoryBot.create(:promoter)
      PersonSession.create(promoter)

      use_ssl
      get :index, params: { person_id: promoter }
      assert_response :success
      assert_select "a[href*='/events']" if css_select(".nav.tabs").present?
    end
  end

  test "index as xml" do
    Timecop.freeze(Time.zone.local(2012, 5)) do
      FactoryBot.create(:event)
      get :index, format: "xml"
      assert_response :success
      assert_equal "application/xml; charset=utf-8", @response.content_type
      [
        "single-day-event > id",
        "single-day-event > name",
        "single-day-event > date"
      ].each { |key| assert_select key }
    end
  end
end
