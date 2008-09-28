require File.dirname(__FILE__) + '/../test_helper'

class TrackControllerTest < ActionController::TestCase
  def test_index
    get(:index)
    assert_response(:success)
    assert_not_nil(assigns["upcoming_events"], 'Should assign @upcoming_events')
  end
  
  def test_schedule
    get(:schedule)
    assert_response(:success)
    assert_not_nil(assigns["events"], 'Should assign @events')
  end
end