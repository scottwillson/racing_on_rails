require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class PostsControllerTest < ActionController::TestCase
  assert_no_angle_brackets :except => [ :test_index ]
  
  def test_mobile_index
    @request.host = "m.cbra.org"
    mailing_list = FactoryGirl.create(:mailing_list)
    get :index, :mailing_list_id => mailing_list.id
    assert_response :success
    assert_not_nil assigns(:posts)
  end
  
  def test_mobile_show
    @request.host = "m.cbra.org"
    new_post = FactoryGirl.create(:post)  
    get :show, :id => new_post.id
    assert_response :success
    assert_not_nil assigns(:post)
  end
end
