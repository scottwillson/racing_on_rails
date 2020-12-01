# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

module Admin
  # :stopdoc:
  class RaceNumbersControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "destroy" do
      race_number = FactoryBot.create(:race_number)
      assert_not_nil(RaceNumber.find(race_number.id), "RaceNumber should exist")

      delete :destroy, params: { id: race_number.to_param }, xhr: true
      assert_response :success

      assert_not RaceNumber.exists?(race_number.id)
    end
  end
end
