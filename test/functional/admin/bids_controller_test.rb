require "test_helper"

class Admin::BidsControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

  def test_index
    opts = {:controller => "admin/bids", :action => "index"}
    assert_routing("/admin/bids", opts)

    get(:index)
    assert_response(:success)
    assert_template("admin/bids/index")
    assert_not_nil(assigns['bids'], 'Should assign bids')
  end
end
