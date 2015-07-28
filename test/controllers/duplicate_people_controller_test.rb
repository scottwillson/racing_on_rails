require_relative("../test_helper")

# :stopdoc:
class DuplicatePeopleControllerTest < ActionController::TestCase
  test "empty index" do
    use_ssl
    login_as :administrator
    get :index
    assert_response :success
  end

  test "index" do
    Person.create!(name: "Sam Willson")
    Person.create!(name: "Sam Willson")
    Person.create!(name: "Steve Smith", other_people_with_same_name: true)
    Person.create!(name: "Steve Smith", other_people_with_same_name: true)
    Person.create!(name: "John Hunt")

    use_ssl
    login_as :administrator
    get :index
    assert_response :success

    assert_select "td", "Sam Willson"
    assert_select "td", text: "John Hunt", count: 0
    assert_select "td", text: "Steve Smith", count: 0
  end

  test "destroy" do
    person_1 = Person.create!(name: "Sam Willson")
    person_2 = Person.create!(name: "Sam Willson")

    use_ssl
    login_as :administrator
    xhr :delete, :destroy, id: "Sam Willson"
    assert_response :success

    assert person_1.reload.other_people_with_same_name?
    assert person_2.reload.other_people_with_same_name?
  end
end
