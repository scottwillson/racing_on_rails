require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class TrackControllerTest < ActionController::TestCase
  def test_index
    FactoryGirl.create(:discipline, name: "Track")
    Event.create! discipline: "Track"
    get(:index)
    assert_response(:success)
    assert_not_nil(assigns["events"], 'Should assign @events')
  end

  def test_schedule
    get :schedule
    assert_redirected_to track_path
  end
end
