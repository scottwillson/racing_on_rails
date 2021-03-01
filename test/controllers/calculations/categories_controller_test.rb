# frozen_string_literal: true

require "test_helper"

module Calculations
  # :stopdoc:
  class CategoriesControllerTest < ActionController::TestCase
    test "redirects to event result page if there is no calculation" do
      event = FactoryBot.create(:event)
      get :index, params: { event_id: event }
      assert_redirected_to event_results_path(event)
    end
  end
end
