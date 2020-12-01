# frozen_string_literal: true

require File.expand_path("../../../test_helper", __dir__)

# :stopdoc:
module Admin
  module People
    class TeamNameChangeTest < ActionController::TestCase
      tests Admin::PeopleController

      def setup
        super
        create_administrator_session
        use_ssl
      end

      test "update team name to new team" do
        assert_nil(Team.find_by(name: "Velo Slop"), "New team Velo Slop should not be in database")
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        put :update_attribute,
            params: {
              id: molly.to_param,
              name: "team_name",
              value: "Velo Slop"
            },
            xhr: true
        assert_response :success
        molly.reload
        assert_equal("Velo Slop", molly.team_name, "Person team name after update")
        assert_not_nil(Team.find_by(name: "Velo Slop"), "New team Velo Slop should be in database")
      end

      test "update team name to existing team" do
        vanilla = Team.create!(name: "Vanilla")
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron", team: vanilla)
        assert_equal(Team.find_by(name: "Vanilla"), molly.team, "Molly should be on Vanilla")
        put :update_attribute,
            params: {
              id: molly.to_param,
              name: "team_name",
              value: "Gentle Lovers"
            },
            xhr: true
        assert_response :success
        molly.reload
        assert_equal("Gentle Lovers", molly.team_name, "Person team name after update")
        assert_equal(Team.find_by(name: "Gentle Lovers"), molly.team, "Molly should be on Gentle Lovers")
      end

      test "update team name to blank" do
        vanilla = Team.create!(name: "Vanilla")
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron", team: vanilla)
        assert_equal(vanilla, molly.team, "Molly should be on Vanilla")
        put :update_attribute,
            params: {
              id: molly.to_param,
              name: "team_name",
              value: ""
            },
            xhr: true
        assert_response :success
        molly.reload
        assert_equal("", molly.team_name, "Person team name after update")
        assert_nil(molly.team, "Molly should have no team")
      end
    end
  end
end
