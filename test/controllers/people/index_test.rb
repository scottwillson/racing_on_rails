# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

# :stopdoc:
class IndexTest < ActionController::TestCase
  tests PeopleController

  test "index" do
    get :index
    assert_response(:success)
    assert_template("people/index")
    assert_template layout: "application"
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_select ".nav.tabs", count: 0
    assert_select "a#export_link", count: 0
  end

  test "list" do
    FactoryBot.create(:person, first_name: "Bob", last_name: "Jones")
    get :list, params: { name: "jone" }
    assert_response(:success)
    assert_not_nil(@response.body.index("Jones"), "Search for jone should find Jones #{@response}")
  end

  test "index as promoter" do
    promoter = FactoryBot.create(:promoter)
    PersonSession.create(promoter)
    get :index
    assert_response(:success)
    assert_template("people/index")
    assert_template layout: "application"
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_select "a#export_link", count: 1
  end

  test "find" do
    weaver = FactoryBot.create(:person)
    get :index, params: { name: "weav" }
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal([weaver], assigns["people"], "Search for weav should find Weaver")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal("weav", assigns["name"], "'name' assigns")
  end

  test "find nothing" do
    get :index, params: { name: "s7dfnacs89danfx" }
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(0, assigns["people"].size, "Should find no people")
  end

  test "find empty name" do
    FactoryBot.create(:person)
    get :index, params: { name: "" }
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal("", assigns["name"], "'name' assigns")
  end

  test "ajax ssl find" do
    FactoryBot.create(:person)
    use_ssl
    get :index, params: { name: "weav" }, xhr: true, format: "json"
    assert @response.body["Weaver"], "Response should include Weaver in #{@response.body}"
    assert_response :success
    assert_template nil
    assert_template layout: nil
  end
end
