require_relative "../racing_on_rails/integration_test"

module Competitions
  # :stopdoc:
  class PublicPagesTest < RacingOnRails::IntegrationTest
    test "redirect event" do
      get "/events/"
      assert_redirected_to schedule_url
    end

    test "schedule" do
      get "/schedule"
      assert_response :success

      get "/schedule.xlsx"
      assert_response :success

      get "/schedule.ics"
      assert_response :success
    end

    test "results pages" do
      FactoryBot.create(:discipline)
      team = FactoryBot.create(:team)
      person = FactoryBot.create(:person, team: team)
      event = FactoryBot.create(:event, date: Date.new(2004, 2))
      senior_men = FactoryBot.create(:category)
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

      result = FactoryBot.create(:result)
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

    test "first aid providers" do
      person = FactoryBot.create(:person_with_login, official: true)
      https! if RacingAssociation.current.ssl?

      get "/admin/first_aid_providers"
      assert_redirected_to new_person_session_url(secure_redirect_options)

      go_to_login
      login person_session: { login: person.login, password: "secret" }
      get "/admin/first_aid_providers"
      assert_response :success
    end

    test "mailing lists" do
      mailing_list = FactoryBot.create(:mailing_list)
      mailing_list_post = FactoryBot.create(:post, mailing_list: mailing_list)

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
  end
end
