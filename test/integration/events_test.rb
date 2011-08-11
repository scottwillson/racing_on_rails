require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EventsTest < ActionController::IntegrationTest
  def test_index
    get "/events"
    assert_redirected_to schedule_path

    get "/events.xml"
    assert_response :success
    xml = Hash.from_xml(@response.body)
    assert_not_nil xml["objects"], "Should have :objects root element in #{xml}"

    get "/events.json"
    assert_response :success
    assert_equal 10, JSON.parse(@response.body).size, "Should have JSON array"
  end
end
