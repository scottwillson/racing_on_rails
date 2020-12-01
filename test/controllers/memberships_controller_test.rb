# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class MembershipsControllerTest < ActionController::TestCase
  test "show" do
    use_ssl
    person = FactoryBot.create(:person)
    login_as person
    get :show, params: { person_id: person }
    assert_equal person, assigns(:person), "@person"
  end
end
