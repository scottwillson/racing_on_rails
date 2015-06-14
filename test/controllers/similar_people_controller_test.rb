require_relative("../test_helper")

# :stopdoc:
class SimilarPeopleControllerTest < ActionController::TestCase
  test "empty index" do
    use_ssl
    login_as :administrator
    get :index
    assert_response :success
  end

  test "index" do
    Person.create!(name: "Sam Willson")
    Person.create!(name: "Sam Willson")

    use_ssl
    login_as :administrator
    get :index
    assert_response :success

    assert_select "td", "Sam Willson"
  end
end
