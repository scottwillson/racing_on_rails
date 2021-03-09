# frozen_string_literal: true

require "test_helper"

module Calculations
  # :stopdoc:
  class ResultsControllerTest < ActionController::TestCase
    setup { FactoryBot.create(:discipline) }

    test "event index" do
      event = FactoryBot.create(:event)
      get :index, params: { event_id: event }
    end

    test "get show by key and year" do
      Calculations::V3::Calculation.create!(key: :owps, year: 2018).create_event!
      get :index, params: { key: :owps, year: 2018 }
      assert_response :redirect
    end

    test "get show by key" do
      Calculations::V3::Calculation.create!(key: :owps).create_event!
      get :index, params: { key: :owps }
      assert_response :redirect
    end

    test "no event" do
      calculation = Calculations::V3::Calculation.create!(key: :oregon_cup)
      get :index, params: { key: :oregon_cup }
      assert_redirected_to calculation_path(calculation)
    end

    test "previous year only" do
      calculation = Calculations::V3::Calculation.create!(year: 3.years.ago.year, key: :oregon_cup)
      get :index, params: { key: :oregon_cup }
      assert_redirected_to calculation_path(calculation)
    end

    test "previous year event only" do
      Calculations::V3::Calculation.create!(year: 3.years.ago.year, key: :oregon_cup).create_event!
      get :index, params: { key: :oregon_cup }
      assert_response :redirect
    end
  end
end
