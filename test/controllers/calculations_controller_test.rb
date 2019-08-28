# frozen_string_literal: true

require "test_helper"

class CalculationsControllerTest < ActionController::TestCase
  test "get index" do
    get :index
    assert_response :success
  end

  test "get show" do
    FactoryBot.create(:discipline)
    calculation = Calculations::V3::Calculation.create!
    get :show, params: { id: calculation.to_param }
    assert_response :success
  end
end
