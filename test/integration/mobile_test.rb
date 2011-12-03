require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class MobileTest < ActionController::IntegrationTest
  def test_popular_pages
    result = FactoryGirl.create(:result)

    get "http://m.cbra.org/"
    assert_response :success
    
    get "http://m.cbra.org/events/#{result.event_id}/races"
    assert_response :success

    get "http://m.cbra.org/schedule"
    assert_response :success

    get "http://m.cbra.org/results"
    assert_response :success
  end
end
