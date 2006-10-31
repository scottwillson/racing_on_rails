require File.dirname(__FILE__) + '/../test_helper'

class DisciplineTest < Test::Unit::TestCase
  
  def teardown
    # Discipline class may have loaded earlier with no aliases in database
    Discipline.reset
  end
  
  # Assume MySQL, which is not case-sensitive
  def test_find_by_name
    assert_equal(disciplines(:road), Discipline.find_by_name("Road"), "Road by name")
    assert_equal(disciplines(:road), Discipline.find_by_name("road"), "road by name")
    assert_equal(disciplines(:cyclocross), Discipline.find_by_name("Cyclocross"), "Cyclocross by name")
    assert_equal(disciplines(:cyclocross), Discipline.find_by_name("cyclocross"), "cyclocross by name")
    assert_equal(nil, Discipline.find_by_name("cx"), "Cyclocross by name")
    assert_equal(disciplines(:mountain_bike), Discipline.find_by_name("Mountain Bike"), "Road by name")
  end
  
  def test_find_by_symbol
    assert_equal(disciplines(:road), Discipline[:road], "Road")
    assert_equal(disciplines(:cyclocross), Discipline[:cyclocross], "Cyclocross")
    assert_equal(disciplines(:mountain_bike), Discipline[:mountain_bike], "mountain_bike")
    assert_equal(disciplines(:time_trial), Discipline[:time_trial], "time_trial")
    assert_equal(disciplines(:cyclocross), Discipline[:cx], "cx")
  end
  
  def test_find_via_alias
    assert_equal(disciplines(:road), Discipline.find_via_alias("Road"), "Road by alias")
    assert_equal(disciplines(:road), Discipline.find_via_alias("road"), "road by alias")
    assert_equal(disciplines(:cyclocross), Discipline.find_via_alias("Cyclocross"), "Cyclocross by alias")
    assert_equal(disciplines(:cyclocross), Discipline.find_via_alias("cyclocross"), "cyclocross by alias")
    assert_equal(disciplines(:cyclocross), Discipline.find_via_alias("cx"), "cyclocross by alias")
  end
end