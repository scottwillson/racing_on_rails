require File.expand_path("../../../test_helper", __FILE__)

class PeopleControllerTest < ActionController::TestCase
  def test_index_as_json
    get :index, :license => 7123811, :format => "xml"
    assert_response :success
    assert_equal "application/xml", @response.content_type
    [
      "person > first-name",
      "person > last-name",
      "person > date-of-birth",
      "person > license",
      "person > gender",
      "person > team",
      "person > race-numbers",
      "person > aliases",
      "team > city",
      "team > state",
      "team > website",
      "race-numbers > race-number",
      "race-number > value",
      "race-number > year",
      "race-number > discipline",
      "discipline > name",
      "aliases > alias",
      "alias > name",
      "alias > alias"
    ].each do |key|
      assert_select key
    end

    get :index, { :format => "json", :name => "ron" }
    assert_response :success
    assert_equal "application/json", @response.content_type
  end
  
  def test_find_by_name_xml
    get :index, :name => "ron", :format => "xml"
    assert_response :success
    assert_select "first-name", "Molly"
    assert_select "first-name", "Kevin"
  end
  
  def test_find_by_license_as_xml
    get :index, :name => "m", :license => 576, :format => "xml"
    assert_response :success
    assert_select "first-name", "Mark"
  end
  
  def test_index_as_json
    get :index, :format => "json", :name => "ron"
    assert_response :success
    assert_equal "application/json", @response.content_type
  end
end
