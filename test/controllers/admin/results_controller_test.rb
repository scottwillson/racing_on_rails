# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

module Admin
  # :stopdoc:
  class ResultsControllerTest < ActionController::TestCase
    def setup
      super
      create_administrator_session
      use_ssl
    end

    test "update no team" do
      result = FactoryBot.create(:result, team: nil)
      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "team_name",
            value: ""
          }
      assert_response(:success)

      result.reload
      assert_nil(result.team, "team")
    end

    test "update no team to existing" do
      result = FactoryBot.create(:result, team: nil)
      FactoryBot.create(:team, name: "Vanilla")

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "team_name",
            value: "Vanilla"
          }

      assert_response(:success)

      result.reload
      assert_equal("Vanilla", result.team.reload.name, "team")
    end

    test "update no team to new" do
      result = FactoryBot.create(:result, team: nil)

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "team_name",
            value: "Team Vanilla"
          }
      assert_response(:success)

      result.reload
      assert_equal("Team Vanilla", result.team.reload.name, "team name")
    end

    test "update no team to alias" do
      result = FactoryBot.create(:result, team: nil)
      gentle_lovers = FactoryBot.create(:team, name: "Gentle Lovers")
      gentle_lovers.aliases.create!(name: "Gentile Lovers")

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "team_name",
            value: "Gentile Lovers"
          }
      assert_response(:success)

      result.reload
      assert_equal(gentle_lovers, result.team.reload, "team")
    end

    test "update to no team" do
      result = FactoryBot.create(:result)

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "team_name",
            value: ""
          }
      assert_response(:success)

      result.reload
      assert_nil(result.team, "team")
    end

    test "update to existing team" do
      result = FactoryBot.create(:result, team: nil)
      vanilla = FactoryBot.create(:team, name: "Vanilla")

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "team_name",
            value: "Vanilla"
          }
      assert_response(:success)

      result.reload
      assert_equal(vanilla, result.team.reload, "team")
    end

    test "update to new team" do
      result = FactoryBot.create(:result, team: nil)

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "team_name",
            value: "Astana"
          }
      assert_response(:success)

      result.reload
      assert_equal("Astana", result.team.reload.name, "team name")
    end

    test "update to team alias" do
      result = FactoryBot.create(:result)
      gentle_lovers = FactoryBot.create(:team, name: "Gentle Lovers")
      gentle_lovers.aliases.create!(name: "Gentile Lovers")

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "team_name",
            value: "Gentile Lovers"
          }
      assert_response(:success)

      result.reload
      assert_equal(gentle_lovers, result.team.reload, "team")
    end

    test "set result points" do
      result = FactoryBot.create(:result)

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "points",
            value: "12"
          }
      assert_response(:success)

      result.reload
      assert_equal(12, result.points, "points")
    end

    test "update no person" do
      result = FactoryBot.create(:result, person: nil)
      original_team_name = result.team_name

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "team_name",
            value: original_team_name
          }
      assert_response(:success)

      result.reload
      assert_nil(result.first_name, "first_name")
      assert_nil(result.last_name, "last_name")
      assert_equal(original_team_name, result.team_name, "team_name")
      assert_nil(result.person, "person")
    end

    test "update no person to existing" do
      result = FactoryBot.create(:result, person: nil)
      tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
      tonkin.aliases.create!(name: "Eric Tonkin")
      original_team_name = result.team_name

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "name",
            value: "Erik Tonkin"
          }
      assert_response(:success)

      result.reload
      assert_equal("Erik Tonkin", result.name, "name")
      assert_equal(original_team_name, result.team_name, "team_name")
      assert_equal(tonkin, result.person.reload, "person")
      assert_equal(1, tonkin.aliases.size)
    end

    test "update no person to alias" do
      result = FactoryBot.create(:result, person: nil)
      tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
      tonkin.aliases.create!(name: "Eric Tonkin")

      original_team_name = result.team_name

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "name",
            value: "Eric Tonkin"
          }
      assert_response(:success)

      result.reload
      assert_equal("Erik Tonkin", result.name, "name")
      assert_equal(original_team_name, result.team_name, "team_name")
      assert_equal(tonkin, result.person.reload, "person")
      assert_equal(1, tonkin.aliases.size)
    end

    test "update to no person" do
      result = FactoryBot.create(:result)

      original_team_name = result.team_name

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "name",
            value: ""
          }
      assert_response(:success)

      result.reload
      assert_nil(result.first_name, "first_name")
      assert_nil(result.last_name, "last_name")
      assert_equal(original_team_name, result.team_name, "team_name")
      assert_nil(result.person, "person")
    end

    test "update to different person" do
      result = FactoryBot.create(:result, person: nil)
      tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
      tonkin.aliases.create!(name: "Eric Tonkin")

      original_team_name = result.team_name

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "name",
            value: "Erik Tonkin"
          }
      assert_response(:success)

      result.reload
      assert_equal("Erik", result.first_name, "first_name")
      assert_equal("Tonkin", result.last_name, "last_name")
      assert_equal(original_team_name, result.team_name, "team_name")
      assert_equal(tonkin, result.person.reload, "person")
      assert_equal(1, tonkin.aliases.size)
    end

    test "update to alias" do
      result = FactoryBot.create(:result, person: nil)
      tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
      tonkin.aliases.create!(name: "Eric Tonkin")
      original_team_name = result.team_name

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "name",
            value: "Eric Tonkin"
          }
      assert_response(:success)

      result.reload
      assert_equal(tonkin, result.person, "Result person")
      assert_equal("Erik", result.first_name, "first_name")
      assert_equal("Tonkin", result.last_name, "last_name")
      assert_equal(original_team_name, result.team_name, "team_name")
      assert_equal(tonkin, result.person.reload, "person")
      assert_equal(1, tonkin.aliases.size)
    end

    test "update to new person" do
      FactoryBot.create(:number_issuer)
      FactoryBot.create(:discipline)

      weaver = FactoryBot.create(:person, first_name: "Ryan", last_name: "Weaver")
      FactoryBot.create_list(:result, 3, person: weaver)
      result = FactoryBot.create(:result, person: weaver)

      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "name",
            value: "Stella Carey"
          }

      assert_response :success

      result = Result.find(result.id)
      assert_equal "Stella", result.first_name, "first_name"
      assert_equal "Carey", result.last_name, "last_name"
      assert weaver != result.person, "Result should be associated with a different person"
      assert_equal 0, result.person.aliases.size, "Result person aliases"
      assert_equal 1, result.person.results.size, "Result person results"
      weaver = Person.find(weaver.id)
      assert_equal 0, weaver.aliases.size, "Weaver aliases"
      assert_equal "Ryan", weaver.first_name, "first_name"
      assert_equal "Weaver", weaver.last_name, "last_name"
      assert_equal 3, weaver.results.size, "results"
    end

    test "update attribute should format times" do
      result = FactoryBot.create(:result, time: 600)
      put :update_attribute,
          xhr: true,
          params: {
            id: result.to_param,
            name: "time",
            value: "7159"
          }

      assert_response :success
      assert_equal "01:59:19.00", response.body, "Should format time but was #{response.body}"
    end

    test "person" do
      weaver = FactoryBot.create(:result).person

      get :index, params: { person_id: weaver.to_param.to_s }

      assert_not_nil(assigns["results"], "Should assign results")
      assert_equal(weaver, assigns["person"], "Should assign person")
      assert_response(:success)
    end

    test "find person" do
      FactoryBot.create(:person, first_name: "Ryan", last_name: "Weaver")
      FactoryBot.create(:person, name: "Alice")
      tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")
      post :find_person, params: { name: "e", ignore_id: tonkin.id }
      assert_response(:success)
      assert_template("admin/results/_people")
    end

    test "find person one result" do
      weaver = FactoryBot.create(:person)
      tonkin = FactoryBot.create(:person, first_name: "Erik", last_name: "Tonkin")

      post :find_person, params: { name: weaver.name, ignore_id: tonkin.id }

      assert_response(:success)
      assert_template("admin/results/_person")
    end

    test "find person no results" do
      tonkin = FactoryBot.create(:person)
      post :find_person, params: { name: "not a person in the database", ignore_id: tonkin.id }
      assert_response(:success)
      assert_template("admin/results/_people")
    end

    test "results" do
      weaver = FactoryBot.create(:result).person

      post :results, params: { person_id: weaver.id }

      assert_response(:success)
      assert_template("admin/results/_person")
    end

    test "scores" do
      result = FactoryBot.create(:result)
      post :scores, params: { id: result.id }, format: "js"
      assert_response(:success)
    end

    test "move" do
      weaver = FactoryBot.create(:result).person
      tonkin = FactoryBot.create(:person)
      result = FactoryBot.create(:result, person: tonkin)

      assert tonkin.results.include?(result)
      assert_not weaver.results.include?(result)

      post :move, params: { person_id: weaver.id, result_id: result.id }, format: "js"

      assert_not tonkin.results.reload.include?(result)
      assert weaver.results.reload.include?(result)
      assert_response :success
    end

    test "create" do
      race = FactoryBot.create(:race)
      tonkin_result = FactoryBot.create(:result, race: race, place: "1")
      weaver_result = FactoryBot.create(:result, race: race, place: "2")
      matson_result = FactoryBot.create(:result, race: race, place: "3")
      molly_result = FactoryBot.create(:result, race: race, place: "16")

      post :create, params: { race_id: race.id, before_result_id: weaver_result.id }, xhr: true
      assert_response(:success)
      assert_equal(5, race.results.size, "Results after insert")
      tonkin_result.reload
      weaver_result.reload
      matson_result.reload
      molly_result.reload
      assert_equal("1", tonkin_result.place, "Tonkin place after insert")
      assert_equal("3", weaver_result.place, "Weaver place after insert")
      assert_equal("4", matson_result.place, "Matson place after insert")
      assert_equal("17", molly_result.place, "Molly place after insert")

      post :create, params: { race_id: race.id, before_result_id: tonkin_result.id }, xhr: true
      assert_response(:success)
      assert_equal(6, race.results.size, "Results after insert")
      tonkin_result.reload
      weaver_result.reload
      matson_result.reload
      molly_result.reload
      assert_equal("2", tonkin_result.place, "Tonkin place after insert")
      assert_equal("4", weaver_result.place, "Weaver place after insert")
      assert_equal("5", matson_result.place, "Matson place after insert")
      assert_equal("18", molly_result.place, "Molly place after insert")

      post :create, params: { race_id: race.id, before_result_id: molly_result.id }, xhr: true
      assert_response(:success)
      assert_equal(7, race.results.size, "Results after insert")
      tonkin_result.reload
      weaver_result.reload
      matson_result.reload
      molly_result.reload
      assert_equal("2", tonkin_result.place, "Tonkin place after insert")
      assert_equal("4", weaver_result.place, "Weaver place after insert")
      assert_equal("5", matson_result.place, "Matson place after insert")
      assert_equal("19", molly_result.place, "Molly place after insert")

      dnf = race.results.create(place: "DNF")
      post :create, params: { race_id: race.id, before_result_id: weaver_result.id }, xhr: true
      assert_response(:success)
      assert_equal(9, race.results.reload.size, "Results after insert")
      tonkin_result.reload
      weaver_result.reload
      matson_result.reload
      molly_result.reload
      dnf.reload
      assert_equal("2", tonkin_result.place, "Tonkin place after insert")
      assert_equal("5", weaver_result.place, "Weaver place after insert")
      assert_equal("6", matson_result.place, "Matson place after insert")
      assert_equal("20", molly_result.place, "Molly place after insert")
      assert_equal("DNF", dnf.place, "DNF place after insert")

      post :create, params: { race_id: race.id, before_result_id: dnf.id }, xhr: true
      assert_response(:success)
      assert_equal(10, race.results.reload.size, "Results after insert")
      tonkin_result.reload
      weaver_result.reload
      matson_result.reload
      molly_result.reload
      dnf.reload
      assert_equal("2", tonkin_result.place, "Tonkin place after insert")
      assert_equal("5", weaver_result.place, "Weaver place after insert")
      assert_equal("6", matson_result.place, "Matson place after insert")
      assert_equal("20", molly_result.place, "Molly place after insert")
      assert_equal("DNF", dnf.place, "DNF place after insert")
      assert_equal("DNF", race.results.reload.max.place, "DNF place after insert")

      post :create, params: { race_id: race.id }, xhr: true
      assert_response(:success)
      assert_equal(11, race.results.reload.size, "Results after insert")
      tonkin_result.reload
      weaver_result.reload
      matson_result.reload
      molly_result.reload
      dnf.reload
      assert_equal("2", tonkin_result.place, "Tonkin place after insert")
      assert_equal("5", weaver_result.place, "Weaver place after insert")
      assert_equal("6", matson_result.place, "Matson place after insert")
      assert_equal("20", molly_result.place, "Molly place after insert")
      assert_equal("DNF", dnf.place, "DNF place after insert")
      assert_equal("DNF", race.results.reload.max.place, "DNF place after insert")
    end

    test "destroy" do
      result_2 = FactoryBot.create(:result)
      assert_not_nil(result_2, "Result should exist in DB")

      post :destroy, params: { id: result_2.to_param }, xhr: true
      assert_response(:success)
      assert_raise(ActiveRecord::RecordNotFound, "Result should not exist in DB") { Result.find(result_2.id) }
    end
  end
end
