require_relative "racing_on_rails/integration_test"

# :stopdoc:
class PublicPagesTest < RacingOnRails::IntegrationTest
  test "results pages" do
    FactoryGirl.create(:discipline)
    team = FactoryGirl.create(:team)
    person = FactoryGirl.create(:person, team: team)
    event = FactoryGirl.create(:event, date: Date.new(2004, 2))
    senior_men = FactoryGirl.create(:category)
    race = event.races.create!(category: senior_men)
    result = race.results.create(place: "1", person: person, team: team)

    get "/people/#{result.person.to_param}"
    assert_response :success
    assert_select "title", /Results: #{result.name}/

    get "/people/#{result.person.to_param}/results"
    assert_response :success
    assert_select "title", /Results: #{result.name}/

    get "/teams/#{team.to_param}"
    assert_response :success
    assert_select "title", /Results: #{team.name}/

    get "/teams/#{team.to_param}/results"
    assert_response :success
    assert_select "title", /Results: #{team.name}/
  end

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
  end

  test "requests for missing team should just redirect to teams page" do
    get "/teams/1"
    assert_redirected_to "/teams"

    get "/teams/1/results"
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

  test "competitions" do
    FactoryGirl.create(:category, name: "Men Cat 1-2")
    FactoryGirl.create(:category, name: "Women Cat 1-2")
    wsba = Competitions::WsbaBarr.create!(date: Date.new(2004))

    get "/wsba_barr/2004"
    assert_response :success
    assert_equal wsba, assigns(:event), "@event"

    rider_rankings = Competitions::RiderRankings.create!(date: Date.new(2004))

    get "/rider_rankings/2004"
    assert_response :success
    assert_equal rider_rankings, assigns(:event), "@event"

    Timecop.freeze(Time.zone.local(2013)) do
      event = Competitions::OregonWomensPrestigeSeries.create!
      get "/owps"
      assert_response :success
      assert_equal event, assigns(:event), "@event"
    end
  end

  test "redirect old schedule URLs" do
    get "/schedule/calendar.xls"
    assert_response :redirect

    get "/schedule/calendar.ics"
    assert_response :redirect

    get "/schedule/calendar.atom"
    assert_response :redirect
  end
end
