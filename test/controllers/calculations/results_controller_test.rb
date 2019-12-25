# frozen_string_literal: true

require "test_helper"

module Calculations
  # :stopdoc:
  class ResultsControllerTest < ActionController::TestCase
    test "event index" do
      event = FactoryBot.create(:event)
      get :index, params: { event_id: event }
    end

    test "get show by key and year no event" do
      FactoryBot.create(:discipline)
      Calculations::V3::Calculation.create!(key: :owps, year: 2018)
      assert_raise(ActionController::RoutingError) { get :index, params: { key: :owps, year: 2018 } }
    end

    test "get show by key no event" do
      FactoryBot.create(:discipline)
      Calculations::V3::Calculation.create!(key: :owps)
      assert_raise(ActionController::RoutingError) { get :index, params: { key: :owps } }
    end

    test "get show by key and year" do
      FactoryBot.create(:discipline)
      Calculations::V3::Calculation.create!(key: :owps, year: 2018).create_event!
      get :index, params: { key: :owps, year: 2018 }
      assert_response :redirect
    end

    test "get show by key" do
      FactoryBot.create(:discipline)
      Calculations::V3::Calculation.create!(key: :owps).create_event!
      get :index, params: { key: :owps }
      assert_response :redirect
    end

    # FIXME: relevant for Calculations?
    # test "race index" do
    #   race = FactoryBot.create(:race)
    #   FactoryBot.create(:discipline)
    #   race.event.calculation = Calculations::V3::Calculation.create!
    #   get :index, params: { race_id: race }
    # end
  end
end
