require File.expand_path("../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class IronmanControllerTest < ActionController::TestCase
    tests IronmanController

    def setup
      super
      big_team = Team.create(name: "T" * 60)
      weaver = FactoryGirl.create(:person, first_name: "f" * 60, last_name: "T" * 60, team: big_team)
      FactoryGirl.create(:race).results.create! person: weaver, team: big_team

      ::Ironman.calculate! 2004
      ::Ironman.calculate!
    end

    test "index with year" do
      get(:index, year: "2004")
      assert_response(:success)
      assert_template("ironman/index")
      assert_not_nil(assigns["ironman"], "Should assign ironman")
      assert_not_nil(assigns["year"], "Should assign year")
      assert_not_nil(assigns["years"], "Should assign years")
    end

    test "index with page" do
      get :index, page: "2", year: "2004"
      assert_response(:success)
      assert_template("ironman/index")
      assert_not_nil(assigns["ironman"], "Should assign ironman")
      assert_not_nil(assigns["year"], "Should assign year")
      assert_not_nil(assigns["years"], "Should assign years")
    end

    test "index with bogus page" do
      get :index, page: "http", year: "2004"
      assert_response(:success)
      assert_template("ironman/index")
      assert_not_nil(assigns["ironman"], "Should assign ironman")
      assert_not_nil(assigns["year"], "Should assign year")
      assert_not_nil(assigns["years"], "Should assign years")
    end

    test "index" do
      get :index
      assert_response(:success)
      assert_template("ironman/index")
      assert_not_nil(assigns["ironman"], "Should assign ironman")
      assert_not_nil(assigns["year"], "Should assign year")
      assert_not_nil(assigns["years"], "Should assign years")
    end
  end
end
