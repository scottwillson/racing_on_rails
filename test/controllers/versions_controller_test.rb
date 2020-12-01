# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class VersionsControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

  test "index for person" do
    person = FactoryBot.create(:person)
    get :index, params: { person_id: person.to_param }
    assert_response :success
    assert_equal person, assigns(:person), "@person"
  end
end
