require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PeopleTest < ActionController::IntegrationTest
  def test_index
    FactoryGirl.create(:person, :first_name => "Ryan", :last_name => "Weaver")
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
  
  def test_import
    goto_login_page_and_login_as FactoryGirl.create(:administrator)
    post "/admin/people/preview_import",  
         :people_file => fixture_file_upload(
           "#{ActionController::TestCase.fixture_path}/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv",
           "text/csv"
          )
    assert_response :success

    assert_not_nil session[:people_file_path], "Should have :people_file_path in session"
    post "/admin/people/import", :commit => "Import"
    assert_redirected_to admin_people_path
  end
end
