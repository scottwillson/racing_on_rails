# frozen_string_literal: true

require "test_helper"

class CalculationsControllerTest < ActionController::TestCase
  test "create" do
    post :create, params: { calculation: { name: "OR TT Cup" } }
    calculation = Calculations::V3::Calculation.last
    assert_equal "OR TT Cup", calculation.name
    assert_redirected_to edit_calculation_path(calculation)
  end

  test "get index" do
    get :index
    assert_response :success
  end

  test "get new" do
    get :new
    assert_response :success
  end

  test "get show" do
    FactoryBot.create(:discipline)
    calculation = Calculations::V3::Calculation.create!
    get :show, params: { id: calculation.to_param }
    assert_response :success
  end
end
