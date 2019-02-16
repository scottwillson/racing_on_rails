# frozen_string_literal: true

require "test_helper"

module Calculations
  # :stopdoc:
  class ResultsControllerTest < ActionController::TestCase
    test "index" do
      event = FactoryBot.create(:event)
      get :index, params: { event_id: event }
    end
  end
end
