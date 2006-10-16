require File.dirname(__FILE__) + '/../test_helper'

class DisciplineTest < Test::Unit::TestCase
  
  fixtures :teams, :racers, :aliases, :disciplines, :aliases_disciplines, :categories, :number_issuers, :race_numbers, :events, :standings, :races, :results

  def setup
    # Discipline class may have loaded earlier with no aliases in database
    Discipline.load_aliases
  end
  
  # Assume MySQL, which is not case-sensitive
  def test_find_by_name
    assert_equal(disciplines(:road), Discipline.find_by_name("Road"), "Road by name")
    assert_equal(disciplines(:road), Discipline.find_by_name("road"), "road by name")
    assert_equal(disciplines(:cyclocross), Discipline.find_by_name("Cyclocross"), "Cyclocross by name")
    assert_equal(disciplines(:cyclocross), Discipline.find_by_name("cyclocross"), "cyclocross by name")
    assert_equal(nil, Discipline.find_by_name("cx"), "Cyclocross by name")
  end
  
  def test_find_via_alias
    assert_equal(disciplines(:road), Discipline.find_via_alias("Road"), "Road by alias")
    assert_equal(disciplines(:road), Discipline.find_via_alias("road"), "road by alias")
    assert_equal(disciplines(:cyclocross), Discipline.find_via_alias("Cyclocross"), "Cyclocross by alias")
    assert_equal(disciplines(:cyclocross), Discipline.find_via_alias("cyclocross"), "cyclocross by alias")
    assert_equal(disciplines(:cyclocross), Discipline.find_via_alias("cx"), "cyclocross by alias")
  end
  
  def test_number_type
    discipline = 'Road'
    assert_equal(:road_number, Discipline.number_type(discipline), "Number type for #{discipline}")
    
    discipline = 'Cyclocross'
    assert_equal(:ccx_number, Discipline.number_type(discipline), "Number type for #{discipline}")
    
    discipline = 'Mountain Bike'
    assert_equal(:xc_number, Discipline.number_type(discipline), "Number type for #{discipline}")
    
    discipline = 'Downhill'
    assert_equal(:dh_number, Discipline.number_type(discipline), "Number type for #{discipline}")
    
    discipline = 'Track'
    assert_equal(:road_number, Discipline.number_type(discipline), "Number type for #{discipline}")
    
    discipline = 'Criterium'
    assert_equal(:road_number, Discipline.number_type(discipline), "Number type for #{discipline}")
    
    discipline = 'Time Trial'
    assert_equal(:road_number, Discipline.number_type(discipline), "Number type for #{discipline}")
    
    discipline = ''
    assert_equal(:road_number, Discipline.number_type(discipline), "Number type for #{discipline}")
  end
end