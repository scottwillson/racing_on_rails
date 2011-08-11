require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::PostsControllerTest < ActionController::TestCase
  setup :use_ssl
  assert_no_angle_brackets :except => [ :test_index ]
  
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
  
  def test_new
    login_as :administrator
    get :new, :mailing_list_id => mailing_lists(:obra_chat).to_param
    assert_response :success
  end
  
  def test_create
    login_as :administrator
    post :create, :mailing_list_id => mailing_lists(:obra_chat).to_param, :post => {
      :from_name => "Mike Murray",
      :from_email_address => "mmurray@obra.org",
      :subject => "No More Masters Races",
      :body => "That is all",
      "date(1i)"=>"2009",
      "date(2i)"=>"11",
      "date(3i)"=>"22"
    }
    assert_not_nil assigns(:post), @post
    assert assigns(:post).errors.empty?, assigns(:post).errors.full_messages.join(", ")
    assert_redirected_to edit_admin_mailing_list_post_path(mailing_lists(:obra_chat), assigns(:post))
  end
  
  def test_receive
    login_as :administrator
    post :receive, :mailing_list_id => mailing_lists(:obra_chat).to_param, :raw => fixture_file_upload("email/for_sale.eml")
    assert_not_nil assigns(:post), @post
    assert assigns(:post).errors.empty?, assigns(:post).errors.full_messages.join(", ")
    assert_redirected_to admin_mailing_list_posts_path(mailing_lists(:obra_chat))
  end
  
  def test_edit
    login_as :administrator
    get :edit, :mailing_list_id => mailing_lists(:obra_chat).to_param, :id => posts(:archived_post).to_param
    assert_response :success
  end
  
  def test_update
    login_as :administrator
    put :update, :mailing_list_id => mailing_lists(:obra_chat).to_param, :id => posts(:archived_post).to_param, :post => {
      :from_name => "Mike Murray",
      :from_email_address => "mmurray@obra.org",
      :subject => "No More Masters Races",
      :body => "That is all",
      "date(1i)"=>"2009",
      "date(2i)"=>"11",
      "date(3i)"=>"22"
    }
    assert_not_nil assigns(:post), @post
    assert assigns(:post).errors.empty?, assigns(:post).errors.full_messages.join(", ")
    assert_equal "No More Masters Races", assigns(:post).subject, "subject"
    assert_redirected_to edit_admin_mailing_list_post_path(mailing_lists(:obra_chat), assigns(:post))
  end

  def test_destroy
    login_as :administrator
    delete :destroy, :mailing_list_id => mailing_lists(:obra_chat).to_param, :id => posts(:archived_post).to_param
    assert_redirected_to admin_mailing_list_posts_path(mailing_lists(:obra_chat))
    assert !Post.exists?(mailing_lists(:obra_chat).id), "Should delete Post"
  end
end
