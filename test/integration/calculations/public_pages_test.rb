# frozen_string_literal: true

require_relative "../racing_on_rails/integration_test"

module Calculations
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

    test "first aid providers" do
      person = FactoryBot.create(:person_with_login, official: true)
      https! if RacingAssociation.current.ssl?

      get "/admin/first_aid_providers"
      assert_redirected_to new_person_session_url

      go_to_login
      login params: { person_session: { login: person.login, password: "secret" } }
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
    end
  end
end
