require "test_helper"

class Api::EventControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_response :success
    assert_equal "application/xml", @response.content_type
    assert_select "discipline", "Time Trial"
    assert_select "name", "Jack Frost"
  end
end
