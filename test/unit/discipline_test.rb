require File.dirname(__FILE__) + '/../test_helper'

class DisciplineTest < ActiveSupport::TestCase
  
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
    assert_equal(disciplines(:mountain_bike), Discipline.find_by_name("Mountain Bike"), "MTB by name")
    assert_equal(disciplines(:bmx), Discipline.find_by_name("BMX"), "BMX by name")
  end
  
  def test_find_by_symbol
    assert_equal(disciplines(:road), Discipline[:road], "Road")
    assert_equal(disciplines(:cyclocross), Discipline[:cyclocross], "Cyclocross")
    assert_equal(disciplines(:mountain_bike), Discipline[:mountain_bike], "mountain_bike")
    assert_equal(disciplines(:time_trial), Discipline[:time_trial], "time_trial")
    assert_equal(disciplines(:cyclocross), Discipline[:cx], "cx")
    assert_equal(disciplines(:bmx), Discipline[:bmx], "bmx")
  end
  
  def test_find_via_alias
    assert_equal(disciplines(:road), Discipline.find_via_alias("Road"), "Road by alias")
    assert_equal(disciplines(:road), Discipline.find_via_alias("road"), "road by alias")
    assert_equal(disciplines(:cyclocross), Discipline.find_via_alias("Cyclocross"), "Cyclocross by alias")
    assert_equal(disciplines(:cyclocross), Discipline.find_via_alias("cyclocross"), "cyclocross by alias")
    assert_equal(disciplines(:cyclocross), Discipline.find_via_alias("cx"), "cyclocross by alias")
  end
  
  def test_find_for_numbers
    disciplines_for_numbers = Discipline.find_for_numbers
    assert(disciplines_for_numbers.size > 2, 'Disciplines for numbers')
    all_disciplines = Discipline.find(:all)
    assert(all_disciplines.size > disciplines_for_numbers.size, 'Should only use a sub-set of Disciplines for numbers')
  end
  
  def test_numbers
    assert_equal(false, Discipline[:circuit].numbers, 'Circuit Race not used for numbers')
    discipline = Discipline.create(:name => 'Unicycle', :numbers => true)
    assert_equal(true, discipline.numbers, 'Unicycle used for numbers')
  end
  
  def test_bar_categories
    cx_bar_cats = disciplines(:cyclocross).bar_categories
    assert_not_nil(cx_bar_cats, 'Cyclocross BAR categories')
    assert(!cx_bar_cats.empty?, 'Cyclocross BAR categories not empty')
  end
  
  def test_names
    assert_equal(%w{ Circuit }, Discipline[:circuit].names, "Circuit names")
    assert_equal(["Downhill", "Mountain Bike"], Discipline[:mountain_bike].names, "Mountain Bike names")
    assert_equal(["Downhill"], Discipline[:downhill].names, "Downhill names")
  end
end