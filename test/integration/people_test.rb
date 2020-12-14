# frozen_string_literal: true

require_relative "racing_on_rails/integration_test"

# :stopdoc:
class PeopleTest < RacingOnRails::IntegrationTest
  test "index" do
    FactoryBot.create(:person, first_name: "Ryan", last_name: "Weaver")
    get "/people"
    assert_response :success

    # MBRA has custom template
    flunk "Expected input#findPerson or input[type=search]" if css_select("input#findPerson").empty? && css_select("input[type=search]").empty?

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

  test "import" do
    FactoryBot.create :discipline
    FactoryBot.create :number_issuer
    goto_login_page_and_login_as FactoryBot.create(:administrator)
    post "/admin/people/preview_import",
         params: {
           people_file: fixture_file_upload(
             "#{ActionController::TestCase.fixture_path}membership/upload.xlsx",
             "application/vnd.ms-excel"
           )
         }
    assert_response :success

    assert_not_nil session[:people_file_path], "Should have :people_file_path in session"
    post "/admin/people/import", params: { commit: "Import" }
    assert_redirected_to admin_people_path
  end
end
