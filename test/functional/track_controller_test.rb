require File.dirname(__FILE__) + '/../test_helper'
require_or_load 'track_controller'

class TrackController; def rescue_action(e) raise e end; end

class TrackControllerTest < ActiveSupport::TestCase

  def setup
    @controller = TrackController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get(:index)
    assert_response(:success)
    assert_not_nil(assigns(:weekly_schedule), "Should assign @weekly_schedule")
  end
end