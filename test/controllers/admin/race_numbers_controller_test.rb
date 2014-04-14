require File.expand_path("../../../test_helper", __FILE__)

module Admin
  # :stopdoc:
  class RaceNumbersControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "destroy" do
      race_number = FactoryGirl.create(:race_number)
      assert_not_nil(RaceNumber.find(race_number.id), 'RaceNumber should exist')

      xhr :delete, :destroy, id: race_number.to_param
      assert_response :success

      assert !RaceNumber.exists?(race_number.id)
    end
  end
end
