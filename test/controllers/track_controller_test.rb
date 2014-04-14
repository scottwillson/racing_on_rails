require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class TrackControllerTest < ActionController::TestCase
  test "index" do
    FactoryGirl.create(:discipline, name: "Track")
    Event.create! discipline: "Track"
    get(:index)
    assert_response(:success)
    assert_not_nil(assigns["events"], 'Should assign @events')
  end

  test "schedule" do
    get :schedule
    assert_redirected_to track_path
  end
end
