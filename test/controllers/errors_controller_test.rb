require "test_helper"

class ErrorsControllerTest < ActionController::TestCase
  test "not_found" do
    get :not_found
    assert_response :success
  end

  test "internal_error" do
    get :internal_error
    assert_response :success
  end

  test "unprocessable_entity" do
    get :unprocessable_entity
    assert_response :success
  end

  test "over_capacity" do
    get :over_capacity
    assert_response :success
  end
end
