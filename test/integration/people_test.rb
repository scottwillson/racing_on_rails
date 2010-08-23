require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PeopleTest < ActionController::IntegrationTest
  def test_index
    get "/people"
    assert_response :success
    assert_select "input[type=text]"

    get "/people.xml?name=weaver"
    assert_response :success
    xml = Hash.from_xml(@response.body)
    assert_not_nil xml["people"], "Should have 'people' root element"
    assert @response.body["Ryan"], "Should find Ryan Weaver"
    assert @response.body["Weaver"], "Should find Ryan Weaver"

    get "/people.json?name=weaver"
    assert_response :success
    assert_equal 1, JSON.parse(@response.body).size, "Should have JSON array"
    assert @response.body["Ryan"], "Should find Ryan Weaver"
    assert @response.body["Weaver"], "Should find Ryan Weaver"
  end
end
