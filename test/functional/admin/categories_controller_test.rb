require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::CategoriesControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

  def test_index
    get(:index)
    assert_response(:success)
    assert_template("admin/categories/index")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_not_nil(assigns["unknowns"], "Should assign unknowns")
  end
  
  def test_not_logged_in
    destroy_person_session
    get(:index)
    assert_redirected_to new_person_session_url(secure_redirect_options)
    assert_nil(@request.session["person"], "No person in session")
  end  
end
