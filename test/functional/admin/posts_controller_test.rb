require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::PostsControllerTest < ActionController::TestCase
  setup :use_ssl
  
  def test_index
    login_as :administrator
    get :index, :mailing_list_id => mailing_lists(:obra_chat).to_param
    assert_response :success
    assert_layout "admin/application"
  end
  
  def test_non_admin_index
    login_as :member
    get :index, :mailing_list_id => mailing_lists(:obra_chat).to_param
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end
  
  def test_index_anonymous
    get :index, :mailing_list_id => mailing_lists(:obra_chat).to_param
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end
end
