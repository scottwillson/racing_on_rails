# frozen_string_literal: true

require File.expand_path("../../../test_helper", __FILE__)

module Admin
  # :stopdoc:
  class TeamsControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "not logged in index" do
      destroy_person_session
      get :index
      assert_redirected_to new_person_session_url
      assert_nil(@request.session["person"], "No person in session")
    end

    test "not logged in edit" do
      destroy_person_session
      vanilla = FactoryBot.create(:team)
      get :edit, params: { id: vanilla.to_param }
      assert_redirected_to new_person_session_url
      assert_nil(@request.session["person"], "No person in session")
    end

    test "find" do
      vanilla = FactoryBot.create(:team, name: "Vanilla Bicycles")
      get :index, params: { name: "van" }
      assert_response(:success)
      assert_template("admin/teams/index")
      assert_not_nil(assigns["teams"], "Should assign teams")
      assert_equal([vanilla], assigns["teams"], "Search for van should find Vanilla")
      assert_not_nil(assigns["name"], "Should assign name")
      assert_equal("van", assigns["name"], "'name' assigns")
    end

    test "find nothing" do
      FactoryBot.create(:team, name: "Vanilla Bicycles")
      FactoryBot.create(:team)

      get :index, params: { name: "s7dfnacs89danfx" }
      assert_response(:success)
      assert_template("admin/teams/index")
      assert_not_nil(assigns["teams"], "Should assign teams")
      assert_equal(0, assigns["teams"].size, "Should find no teams")
    end

    test "find empty name" do
      FactoryBot.create(:team, name: "Vanilla Bicycles")

      get :index, params: { name: "" }
      assert_response(:success)
      assert_template("admin/teams/index")
      assert_not_nil(assigns["teams"], "Should assign teams")
      assert_equal(0, assigns["teams"].size, "Search for '' should find no teams")
      assert_not_nil(assigns["name"], "Should assign name")
      assert_equal("", assigns["name"], "'name' assigns")
    end

    test "index" do
      get :index
      assert_response(:success)
      assert_template("admin/teams/index")
      assert_not_nil(assigns["teams"], "Should assign teams")
      assert(assigns["teams"].empty?, "Should have no people")
      assert_not_nil(assigns["name"], "Should assign name")
    end

    test "index with cookie" do
      FactoryBot.create(:team, name: "Gentle Lovers")
      @request.cookies["team_name"] = "gentle"
      get :index
      assert_response(:success)
      assert_template("admin/teams/index")
      assert_not_nil(assigns["teams"], "Should assign teams")
      assert_equal("gentle", assigns["name"], "Should assign name")
      assert_equal(1, assigns["teams"].size, "Should have no teams")
    end

    test "index rjs" do
      vanilla = FactoryBot.create(:team, name: "Vanilla Bicycles")
      get :index, params: { name: "nilla" }, xhr: true
      assert_response(:success)
      assert_template("admin/teams/index")
      assert_not_nil(assigns["teams"], "Should assign teams")
      assert_equal([vanilla], assigns["teams"], "Search for nilla should find Vanilla")
    end

    test "blank name" do
      vanilla = FactoryBot.create(:team, name: "Vanilla Bicycles")
      assert_raise(ActiveRecord::RecordInvalid) do
        put :update_attribute,
          params: {
            id: vanilla.to_param,
            name: "name",
            value: ""
          },
          xhr: true
      end
      assert_template(nil)
      assert_not_nil(assigns["team"], "Should assign team")
      assert(!assigns["team"].errors.empty?, "Attempt to assign blank name should add error")
      assert_equal(vanilla, assigns["team"], "Team")
      vanilla.reload
      assert_equal("Vanilla Bicycles", vanilla.name, "Team name")
    end

    test "set name" do
      vanilla = FactoryBot.create(:team, name: "Vanilla Bicycles")
      put :update_attribute,
        params: {
          id: vanilla.to_param,
          name: "name",
          value: "Vaniller"
        },
        xhr: true
      assert_response(:success)
      assert_not_nil(assigns["team"], "Should assign team")
      assert_equal(vanilla, assigns["team"], "Team")
      assert assigns["team"].errors.empty?, assigns["team"].errors.full_messages.join
      assert_template(nil)
      vanilla.reload
      assert_equal("Vaniller", vanilla.name, "Team name after update")
    end

    test "set name same name" do
      vanilla = FactoryBot.create(:team, name: "Vanilla Bicycles")
      put :update_attribute,
        params: {
          id: vanilla.to_param,
          name: "name",
          value: "Vanilla"
        },
        xhr: true
      assert_response(:success)
      assert_template(nil)
      assert_not_nil(assigns["team"], "Should assign team")
      assert_equal(vanilla, assigns["team"], "Team")
      vanilla.reload
      assert_equal("Vanilla", vanilla.name, "Team name after update")
    end

    test "set name same name different case" do
      vanilla = FactoryBot.create(:team, name: "Vanilla Bicycles")
      put :update_attribute,
        params: {
          id: vanilla.to_param,
          name: "name",
          value: "vanilla"
        },
        xhr: true
      assert_response(:success)
      assert_template(nil)
      assert_not_nil(assigns["team"], "Should assign team")
      assert_equal(vanilla, assigns["team"], "Team")
      vanilla.reload
      assert_equal("vanilla", vanilla.name, "Team name after update")
    end

    test "set name to existing name" do
      vanilla = FactoryBot.create(:team, name: "Vanilla Bicycles")
      FactoryBot.create(:team, name: "Kona")

      put :update_attribute,
        params: {
          id: vanilla.to_param,
          name: "name",
          value: "Kona"
        },
        xhr: true
      assert_response(:success)
      assert_template("admin/teams/merge_confirm")
      assert_not_nil(assigns["team"], "Should assign team")
      assert_equal(vanilla, assigns["team"], "Team")
      assert_not_nil(Team.find_by(name: "Vanilla Bicycles"), "Vanilla still in database")
      assert_not_nil(Team.find_by(name: "Kona"), "Kona still in database")
      vanilla.reload
      assert_equal("Vanilla Bicycles", vanilla.name, "Team name after cancel")
    end

    test "set name to existing alias" do
      vanilla = FactoryBot.create(:team, name: "Vanilla")
      vanilla.aliases.create!(name: "Vanilla Bicycles")

      put :update_attribute,
        params: {
          id: vanilla.to_param,
          name: "name",
          value: "Vanilla Bicycles"
        },
        xhr: true
      assert_response(:success)
      assert_not_nil(assigns["team"], "Should assign team")
      assert assigns["team"].errors.empty?, assigns["team"].errors.full_messages.join
      assert_template(nil)
      assert_equal(vanilla, assigns["team"], "Team")
      vanilla.reload
      assert_equal("Vanilla Bicycles", vanilla.name, "Team name after cancel")
      vanilla_alias = Alias.find_by(name: "Vanilla")
      assert_not_nil(vanilla_alias, "Alias")
      assert_equal(vanilla, vanilla_alias.team, "Alias team")
      old_vanilla_alias = Alias.find_by(name: "Vanilla Bicycles")
      assert_nil(old_vanilla_alias, "Alias")
    end

    test "set name to existing alias different case" do
      vanilla = FactoryBot.create(:team, name: "Vanilla")
      vanilla.aliases.create!(name: "Vanilla Bicycles")

      vanilla = vanilla
      put :update_attribute,
        params: {
          id: vanilla.to_param,
          name: "name",
          value: "vanilla bicycles"
        },
        xhr: true
      assert_response(:success)
      assert_template(nil)
      assert_not_nil(assigns["team"], "Should assign team")
      assert_equal(vanilla, assigns["team"], "Team")
      vanilla.reload
      assert_equal("vanilla bicycles", vanilla.name, "Team name after update")
      vanilla_alias = Alias.find_by(name: "Vanilla")
      assert_not_nil(vanilla_alias, "Alias")
      assert_equal(vanilla, vanilla_alias.team, "Alias team")
      old_vanilla_alias = Alias.find_by(name: "vanilla bicycles")
      assert_nil(old_vanilla_alias, "Alias")
    end

    test "set name to other team existing alias" do
      vanilla = FactoryBot.create(:team, name: "Vanilla")
      vanilla.aliases.create!(name: "Vanilla Bicycles")

      kona = FactoryBot.create(:team, name: "Kona")

      put :update_attribute,
          xhr: true,
          params: {
            id: kona.to_param,
            name: "name",
            value: "Vanilla Bicycles"
          }
      assert_response(:success)
      assert_template("admin/teams/merge_confirm")
      assert_not_nil(assigns["team"], "Should assign team")
      assert_equal(kona, assigns["team"], "Team")
      assert_equal([vanilla], assigns["other_teams"], "existing_teams")
      assert_not_nil(Team.find_by(name: "Kona"), "Kona still in database")
      assert_not_nil(Team.find_by(name: "Vanilla"), "Vanilla still in database")
      assert_nil(Team.find_by(name: "Vanilla Bicycles"), "Vanilla Bicycles not in database")
    end

    test "set name land shark bug" do
      landshark = Team.create(name: "Landshark")
      landshark.aliases.create(name: "Landshark")
      landshark.aliases.create(name: "Land Shark")
      landshark.aliases.create(name: "Team Landshark")

      put :update_attribute,
          params: {
            id: landshark.to_param,
            name: "name",
            value: "Land Shark"
          },
          xhr: true
      assert_response(:success)
      assert_not_nil(assigns["team"], "Should assign team")
      assert assigns["team"].errors.empty?, assigns["team"].errors.full_messages.join
      assert_template(nil)
      assert_equal(landshark, assigns["team"], "Team")
      landshark.reload
      assert_equal("Land Shark", landshark.name, "Updated name")
      assert_equal(2, landshark.aliases.reload.size, "Aliases")
      assert(landshark.aliases.any? { |a| a.name == "Landshark" }, "Aliases should include Landshark")
      assert(landshark.aliases.none? { |a| a.name == "Land Shark" }, "Aliases should not include Land Shark")
      assert(landshark.aliases.none? { |a| a.name == "LandTeam Landshark" }, "Aliases should not include Team Landshark")
      # try with different cases
    end

    test "destroy" do
      csc = Team.create!(name: "CSC")
      delete :destroy, params: { id: csc.id }
      assert_redirected_to(admin_teams_path)
      assert(!Team.exists?(csc.id), "CSC should have been destroyed")
    end

    test "destroy team with results should not cause hard errors" do
      team = FactoryBot.create(:result).team
      delete :destroy, params: { id: team.id }
      assert(Team.exists?(team.id), "Team should not have been destroyed")
      assert(!assigns(:team).errors.empty?, "Team should have error")
      assert_response(:success)
    end

    test "merge?" do
      vanilla = FactoryBot.create(:team, name: "Vanilla")
      kona = FactoryBot.create(:team)
      put :update_attribute,
          params: {
            id: kona.to_param,
            name: "name",
            value: "Vanilla"
          },
          xhr: true
      assert_response(:success)
      assert_template("admin/teams/merge_confirm")
      assert_equal(kona, assigns["team"], "Team")
      assert_equal(vanilla.name, assigns["team"].name, "Unsaved Kona name should be Vanilla")
      assert_equal([vanilla], assigns["other_teams"], "Existing Team")
    end

    test "merge" do
      vanilla = FactoryBot.create(:team, name: "Vanilla")
      kona = FactoryBot.create(:team, name: "Kona")
      assert(Team.find_by(name: "Kona"), "Kona should be in database")

      post :merge, params: { id: vanilla.id, other_team_id: kona.to_param }, xhr: true
      assert_response(:success)
      assert_template("admin/teams/merge")

      assert(Team.find_by(name: "Vanilla"), "Vanilla should be in database")
      assert_nil(Team.find_by(name: "Kona"), "Kona should not be in database")
    end

    test "toggle member" do
      vanilla = FactoryBot.create(:team, name: "Vanilla")
      result = FactoryBot.create(:result, team: vanilla)

      assert vanilla.member?, "member before update"
      post :toggle_member, params: { id: vanilla.to_param }
      assert_response(:success)
      assert_template("shared/_member")
      vanilla.reload
      assert_not vanilla.member?, "member after update"
      assert_not result.reload.team_member?, "Result#team_member should be updated"

      post :toggle_member, params: { id: vanilla.to_param }
      assert_response(:success)
      assert_template("shared/_member")
      vanilla.reload
      assert vanilla.member?, "member after second update"
      assert_equal true, result.reload.team_member?, "Result#team_member should be updated"
    end

    test "edit" do
      vanilla = FactoryBot.create(:team, name: "Vanilla")
      get :edit, params: { id: vanilla.to_param }
      assert_response(:success)
      assert_template("admin/teams/edit")
      assert_not_nil(assigns["team"], "Should assign team")
      assert_equal(vanilla, assigns["team"], "Should assign Vanilla to team")
    end

    test "destroy name" do
      vanilla = FactoryBot.create(:team, name: "Vanilla")
      vanilla.names.create!(name: "Generic Team", year: 1990)
      assert_equal(1, vanilla.names.count, "Vanilla names")
      name = vanilla.names.first

      post :destroy_name, params: { id: vanilla.to_param, name_id: name.to_param }, xhr: true
      assert_response(:success)
      assert_equal(0, vanilla.names.reload.count, "Vanilla names after destruction")
    end

    test "new" do
      get(:new)
      assert_response(:success)
      assert_not_nil(assigns(:team), "@team")
    end

    test "create" do
      post :create, params: { team: { name: "My Fancy New Bike Team" } }
      team = Team.find_by(name: "My Fancy New Bike Team")
      assert_not_nil(team, "Should create new team")
      assert_redirected_to(edit_admin_team_path(team))
    end

    test "update" do
      team = FactoryBot.create(:team, name: "Vanilla")
      post :update,
           params: {
             id: team.to_param,
             team: { name: "Speedvagen",
                     website: "http://speedvagen.net",
                     sponsors: %(<a href="http://stumptowncoffeeroasters">Stumptown</a>),
                     contact_name: "Sacha White",
                     contact_email: "sacha@speedvagen.net",
                     contact_phone: "14115555",
                     member: true
                   }
                 }
      assert_redirected_to(edit_admin_team_path(team))
      team.reload
      assert_equal("Speedvagen", team.name, "Name should be updated")
      assert_equal("http://speedvagen.net", team.website, "website should be updated")
      assert_equal(%(<a href="http://stumptowncoffeeroasters">Stumptown</a>), team.sponsors, "sponsors should be updated")
      assert_equal("Sacha White", team.contact_name, "contact_name should be updated")
      assert_equal("sacha@speedvagen.net", team.contact_email, "contact_email should be updated")
      assert_equal("14115555", team.contact_phone, "contact_phone should be updated")
      assert(team.member?, "member should be updated")
    end

    test "invalid update" do
      team = FactoryBot.create(:team, name: "Vanilla")
      post :update, params: { id: team.to_param, team: { name: "" } }
      assert_response :success
      assert_not_nil assigns(:team), "@team"
      assert !assigns(:team).errors.empty?, "@team should have errors"
    end
  end
end
