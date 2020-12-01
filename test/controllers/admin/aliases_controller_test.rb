# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

module Admin
  # :stopdoc:
  class AliasesControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "destroy person alias" do
      person = FactoryBot.create(:person)
      person_alias = person.aliases.create!(name: "Alias")
      delete :destroy, params: { id: person_alias.to_param, person_id: person_alias.person.to_param, format: "js" }
      assert_response :success
      assert_not Alias.exists?(person_alias.id), "alias"
    end

    test "destroy team alias" do
      team = FactoryBot.create(:team)
      team_alias = team.aliases.create!(name: "Alias")
      delete :destroy, params: { id: team_alias.to_param, team_id: team_alias.team.to_param, format: "js" }
      assert_response :success
      assert_not Alias.exists?(team_alias.id), "alias"
    end
  end
end
