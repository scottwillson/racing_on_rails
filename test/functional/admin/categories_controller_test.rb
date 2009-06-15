require "test_helper"

class Admin::CategoriesControllerTest < ActionController::TestCase
  setup :create_administrator_session

  def test_index
    opts = {:controller => "admin/categories", :action => "index"}
    assert_routing("/admin/categories", opts)
    get(:index)
    assert_response(:success)
    assert_template("admin/categories/index")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_not_nil(assigns["unknowns"], "Should assign unknowns")
  end
  
  def test_not_logged_in
    destroy_user_session
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(new_user_session_path)
    assert_nil(@request.session["user"], "No user in session")
  end  
end