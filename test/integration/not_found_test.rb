require_relative "racing_on_rails/integration_test"

# :stopdoc:
class NotFoundTest < RacingOnRails::IntegrationTest
  test "requests for missing events should just redirect to event results page" do
    get "/events/2"
    assert_redirected_to "/schedule"

    get "/events/2/results"
    assert_redirected_to "/schedule"
  end

  test "requests for missing people should just redirect to people page" do
    get "/people/22530"
    assert_redirected_to "/people"

    get "/people/22530/results"
    assert_redirected_to "/people"

    get "/events/1/people/22530/results"
    assert_redirected_to "/people"
  end

  test "requests for missing team should just redirect to teams page" do
    get "/teams/1"
    assert_redirected_to "/teams"

    get "/teams/1/results"
    assert_redirected_to "/teams"

    get "/events/1/teams/22530/results"
    assert_redirected_to "/teams"
  end

  test "requests for missing posts should redirect to mailing lists" do
    get "/posts/1"
    assert_redirected_to "/mailing_lists"
  end

  test "API request for missing models should just return 404" do
    get "/people/22530/results.json"
    assert_response :not_found

    get "/people/22530/results.xml"
    assert_response :not_found

    get "/teams/1/results.json"
    assert_response :not_found

    get "/teams/1/results.xml"
    assert_response :not_found
  end
end
