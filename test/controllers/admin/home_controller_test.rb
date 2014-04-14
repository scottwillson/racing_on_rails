require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  class HomeControllerTest < ActionController::TestCase
    setup :create_administrator_session, :use_ssl

    test "index" do
      get :index
      assert_redirected_to admin_events_path
    end
  end
end
