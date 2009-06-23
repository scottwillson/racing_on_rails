require "test_helper"

class PeopleControllerTest < ActionController::TestCase
  def test_index
    get(:index)
    assert_response(:success)
    assert_template("people/index")
    assert_layout("application")
    assert_not_nil(assigns["people"], "Should assign people")
    assert(!assigns["people"].empty?, "Should find and paginate all people")
    assert_not_nil(assigns["name"], "Should assign name")
  end

  def test_find
    get(:index, :name => 'weav')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal([people(:weaver)], assigns['people'], 'Search for weav should find Weaver')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_nothing
    get(:index, :name => 's7dfnacs89danfx')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(0, assigns['people'].size, "Should find no people")
  end
  
  def test_find_empty_name
    get(:index, :name => '')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(10, assigns['people'].size, "Search for '' should find all people")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_limit
    for i in 0..SEARCH_RESULTS_LIMIT
      Person.create(:name => "Test Person #{i}")
    end
    get(:index, :name => 'Test')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(30, assigns['people'].size, "Search for '' should find all people and paginate")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(flash.empty?, 'flash not empty?')
    assert_equal('', assigns['name'], "'name' assigns")
  end
end
