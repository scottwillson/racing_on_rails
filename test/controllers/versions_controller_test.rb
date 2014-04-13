require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class VersionsControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

  def test_index_for_person
    person = FactoryGirl.create(:person)
    get :index, :person_id => person.to_param
    assert_response :success
    assert_equal person, assigns(:person), "@person"
  end
end
