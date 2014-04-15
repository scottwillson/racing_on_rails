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
end
