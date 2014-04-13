require File.expand_path("../../../../test_helper", __FILE__)

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

      def test_update_team_name_to_new_team
        assert_nil(Team.find_by_name('Velo Slop'), 'New team Velo Slop should not be in database')
        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        xhr :put, :update_attribute,
            :id => molly.to_param,
            :name => "team_name",
            :value => "Velo Slop"
        assert_response :success
        molly.reload
        assert_equal('Velo Slop', molly.team_name, 'Person team name after update')
        assert_not_nil(Team.find_by_name('Velo Slop'), 'New team Velo Slop should be in database')
      end

      def test_update_team_name_to_existing_team
        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        assert_equal(Team.find_by_name('Vanilla'), molly.team, 'Molly should be on Vanilla')
        xhr :put, :update_attribute,
            :id => molly.to_param,
            :name => "team_name",
            :value => "Gentle Lovers"
        assert_response :success
        molly.reload
        assert_equal('Gentle Lovers', molly.team_name, 'Person team name after update')
        assert_equal(Team.find_by_name('Gentle Lovers'), molly.team, 'Molly should be on Gentle Lovers')
      end

      def test_update_team_name_to_blank
        molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
        assert_equal(Team.find_by_name('Vanilla'), molly.team, 'Molly should be on Vanilla')
        xhr :put, :update_attribute,
            :id => molly.to_param,
            :name => "team_name",
            :value => ""
        assert_response :success
        molly.reload
        assert_equal('', molly.team_name, 'Person team name after update')
        assert_nil(molly.team, 'Molly should have no team')
      end
    end
  end
end
