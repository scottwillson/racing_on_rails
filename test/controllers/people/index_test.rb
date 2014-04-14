# coding: utf-8

require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class IndexTest < ActionController::TestCase
  tests PeopleController

  test "index" do
    get(:index)
    assert_response(:success)
    assert_template("people/index")
    assert_template layout: "application"
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_select ".nav.tabs", count: 0
    assert_select "a#export_link", count: 0
  end

  test "list" do
    FactoryGirl.create(:person, first_name: "Bob", last_name: "Jones")
    get(:list, name: 'jone')
    assert_response(:success)
    assert_not_nil(@response.body.index("Jones"), "Search for jone should find Jones #{@response}")
  end

  test "index as promoter" do
    promoter = FactoryGirl.create(:promoter)
    PersonSession.create(promoter)
    get(:index)
    assert_response(:success)
    assert_template("people/index")
    assert_template layout: "application"
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_select "a#export_link", count: 1
  end

  test "find" do
    weaver = FactoryGirl.create(:person)
    get(:index, name: "weav")
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal([weaver], assigns['people'], 'Search for weav should find Weaver')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('weav', assigns['name'], "'name' assigns")
  end

  test "find nothing" do
    get(:index, name: 's7dfnacs89danfx')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(0, assigns['people'].size, "Should find no people")
  end

  test "find empty name" do
    FactoryGirl.create(:person)
    get(:index, name: '')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  test "find limit" do
    for i in 0..RacingAssociation.current.search_results_limit
      Person.create(name: "Test Person #{i}")
    end
    get(:index, name: 'Test')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(100, assigns['people'].size, "Search results should be cut off at RacingAssociation.current.search_results_limit")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(flash.empty?, 'flash not empty?')
    assert_equal('Test', assigns['name'], "'name' assigns")
  end

  test "ajax ssl find" do
    FactoryGirl.create(:person)
    use_ssl
    xhr :get, :index, name: "weav", format: "json"
    assert @response.body["Weaver"], "Response should include Weaver in #{@response.body}"
    assert_response :success
    assert_template nil
    assert_template layout: nil
  end

end
