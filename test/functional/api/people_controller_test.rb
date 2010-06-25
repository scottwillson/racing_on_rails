require "test_helper"

class Api::PersonControllerTest < ActionController::TestCase
  def test_index
    get :index, { :license => 7123811 }
    assert_response :success
    assert_equal "application/xml", @response.content_type
    assert_select "first-name", "Erik"
    assert_select "last-name", "Tonkin"
    assert_select "date-of-birth", "1980-06-25"
    assert_select "license", "7123811"
    assert_select "gender", "M"

    get :index, { :name => "ron" }
    assert_response :success
    assert_select "first-name", "Molly"
    assert_select "first-name", "Kevin"

    get :index, { :name => "m", :license => 576 }
    assert_response :success
    assert_select "first-name", "Mark"

    get :index, { :format => "json", :name => "ron" }
    assert_response :success
    assert_equal "application/json", @response.content_type
  end
end
