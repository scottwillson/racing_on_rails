# frozen_string_literal: true

require File.expand_path("../../../test_helper", __dir__)

# :stopdoc:
module Admin
  module People
    class IndexTest < ActionController::TestCase
      tests Admin::PeopleController

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
        person = FactoryBot.create(:person)
        get :edit, params: { id: person.to_param }
        assert_nil(@request.session["person"], "No person in session")
        assert_redirected_to new_person_session_url
      end

      test "index" do
        get :index
        assert_response :success
        assert_template("admin/people/index")
        assert_template layout: "admin/application"
        assert_not_nil(assigns["people"], "Should assign people")
        assert(assigns["people"].empty?, "Should have no people")
      end

      test "find" do
        person = FactoryBot.create(:person)
        get :index, params: { name: "weav" }
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal([person], assigns["people"], "Search for weav should find Weaver")
        assert_not_nil(assigns["name"], "Should assign name")
        assert_equal("weav", assigns["name"], "'name' assigns")
      end

      test "find by number" do
        FactoryBot.create(:discipline)
        FactoryBot.create(:number_issuer)
        person = FactoryBot.create(:person, road_number: "777")
        get :index, params: { name: "777" }
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal([person], assigns["people"], "Search for race number should find person")
        assert_not_nil(assigns["name"], "Should assign name")
        assert_equal("777", assigns["name"], "'name' assigns")
      end

      test "find nothing" do
        FactoryBot.create(:person)
        get :index, params: { name: "s7dfnacs89danfx" }
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal(0, assigns["people"].size, "Should find no people")
      end

      test "find empty name" do
        get :index, params: { name: "" }
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal(0, assigns["people"].size, "Search for '' should find no people")
        assert_not_nil(assigns["name"], "Should assign name")
        assert_equal("", assigns["name"], "'name' assigns")
      end

      test "find limit" do
        FactoryBot.create_list(:person, 100)
        get :index, params: { name: "Ryan" }
        assert_response :success
        assert_template("admin/people/index")
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal(30, assigns["people"].size, "Search for '' should find all people")
        assert_not_nil(assigns["name"], "Should assign name")
        assert_equal("Ryan", assigns["name"], "'name' assigns")
      end

      test "blank name" do
        molly = FactoryBot.create(:person, first_name: "Molly", last_name: "Cameron")
        put :update_attribute,
            xhr: true,
            params: {
              id: molly.to_param,
              name: "name",
              value: ""
            }
        assert_response :success
        person = assigns["person"]
        assert_equal molly, person, "@person"
        assert person.errors.empty?, "Should have no errors, but had: #{person.errors.full_messages.join(', ')}"
        molly.reload
        assert_equal "", molly.first_name, "Person first_name after update"
        assert_equal "", molly.last_name, "Person last_name after update"
      end

      test "index with cookie" do
        FactoryBot.create(:person)
        @request.cookies["person_name"] = "weaver"
        get :index
        assert_response :success
        assert_not_nil(assigns["people"], "Should assign people")
        assert_equal("weaver", assigns["name"], "Should assign name")
        assert_equal(1, assigns["people"].size, "Should have no people")
      end
    end
  end
end
