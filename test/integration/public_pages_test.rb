require_relative "racing_on_rails/integration_test"

# :stopdoc:
class PublicPagesTest < RacingOnRails::IntegrationTest
  def test_redirect_event
    get "/events/"
    assert_redirected_to schedule_url
  end

  def test_schedule
    get "/schedule"
    assert_response :success

    get "/schedule.xls"
    assert_response :success

    get "/schedule.ics"
    assert_response :success
  end

  def test_results_pages
    FactoryGirl.create(:discipline)
    team = FactoryGirl.create(:team)
    person = FactoryGirl.create(:person, team: team)
    event = FactoryGirl.create(:event, date: Date.new(2004, 2))
    senior_men = FactoryGirl.create(:category)
    race = event.races.create!(category: senior_men)
    result = race.results.create(place: "1", person: person, team: team)

    Ironman.calculate! 2004
    event = Ironman.find_for_year(2004)
    result = event.races.first.results.first
    race = result.race
    get "/events/#{event.to_param}/people/#{person.to_param}/results"
    assert_response :success
    assert_select "a", result.name
    assert_select "h2", result.name

    get "/events/#{event.to_param}/teams/#{team.to_param}/results/#{race.to_param}"
    assert_response :success
    assert_select "a", result.team_name
    assert_select "h2", result.team_name

    result = FactoryGirl.create(:result)
    get "/events/#{result.event.to_param}"
    assert_response :success
    assert_select ".name a", result.name
    assert_select "h2", result.event.full_name

    get "/events/#{result.event.to_param}/results"
    assert_response :success
    assert_select ".name a", result.name
    assert_select "h2", result.event.full_name

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

  def test_first_aid_providers
    person = FactoryGirl.create(:person_with_login, official: true)
    https! if RacingAssociation.current.ssl?

    get "/admin/first_aid_providers"
    assert_redirected_to new_person_session_url(secure_redirect_options)

    go_to_login
    login person_session: { login: person.login, password: "secret" }
    get "/admin/first_aid_providers"
    assert_response :success
  end

  def test_mailing_lists
    mailing_list = FactoryGirl.create(:mailing_list)
    mailing_list_post = FactoryGirl.create(:post, mailing_list: mailing_list)

    get "/"
    assert_response :success

    get "/mailing_lists"
    assert_response :success

    get "/mailing_lists/#{mailing_list.id}/posts"
    assert_response :success

    get "/posts/#{mailing_list_post.id}"
    assert_response :success

    get "/mailing_lists/#{mailing_list.id}/posts/new"
    assert_response :success
  end

  def test_competitions
    category_men_1_2 = FactoryGirl.create(:category, name: "Men Cat 1-2")
    sr_women = FactoryGirl.create(:category, name: "Women Cat 1-2")
    wsba = WsbaBarr.create!(date: Date.new(2004))

    get "/wsba_barr/2004"
    assert_response :success
    assert_equal wsba, assigns(:event), "@event"

    rider_rankings = RiderRankings.create!(date: Date.new(2004))

    get "/rider_rankings/2004"
    assert_response :success
    assert_equal rider_rankings, assigns(:event), "@event"

    Timecop.freeze(Time.zone.local(2013)) do
      event = OregonWomensPrestigeSeries.create!
      get "/owps"
      assert_response :success
      assert_equal event, assigns(:event), "@event"
    end
  end
end
