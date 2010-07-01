require File.expand_path("../../test_helper", __FILE__)

class MembershipsControllerTest < ActionController::TestCase
  def test_show
    login_as :member
    person = people(:member)
    get :show, :person_id => person
    assert_equal person, assigns(:person), "@person"
  end
end
