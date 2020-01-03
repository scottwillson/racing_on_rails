# frozen_string_literal: true

require_relative "racing_on_rails/integration_test"

# :stopdoc:
class PublicPagesIntegrationTest < RacingOnRails::IntegrationTest
  test "results pages" do
    FactoryBot.create(:discipline)
    team = FactoryBot.create(:team)
    person = FactoryBot.create(:person, team: team)
    event = FactoryBot.create(:event, date: Date.new(2004, 2))
    senior_men = FactoryBot.create(:category)
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

  test "home" do
    get "/home"
    assert_redirected_to "/"
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
