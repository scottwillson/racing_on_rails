require "test_helper"

class Admin::CategoriesControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

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
    destroy_person_session
    get(:index)
    assert_redirected_to(new_person_session_path)
    assert_nil(@request.session["person"], "No person in session")
  end  
end