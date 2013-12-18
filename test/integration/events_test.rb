require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EventsTest < ActionController::IntegrationTest
  def test_index
    Timecop.freeze(Time.zone.local(2013, 3)) do
      FactoryGirl.create(:event)
      FactoryGirl.create(:event)
    
      get "/events"
      assert_redirected_to schedule_path

      get "/events.xml"
      assert_response :success
      xml = Hash.from_xml(response.body)
      assert_not_nil xml["single_day_events"], "Should have :single_day_events root element in #{xml}"

      get "/events.json"
      assert_response :success
      assert_equal 2, JSON.parse(response.body).size, "Should have JSON array"
    end
  end
end
