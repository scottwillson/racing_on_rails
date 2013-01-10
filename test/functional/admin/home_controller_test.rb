require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
module Admin
  class HomeControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    def test_index
      get :index
      assert_redirected_to admin_events_path
    end
  end
end
