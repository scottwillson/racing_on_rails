require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class MembershipsControllerTest < ActionController::TestCase
  def test_show
    person = FactoryGirl.create(:person)
    login_as person
    get :show, :person_id => person
    assert_equal person, assigns(:person), "@person"
  end
end
