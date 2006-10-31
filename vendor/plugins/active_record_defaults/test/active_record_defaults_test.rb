require File.dirname(__FILE__) + '/abstract_unit'

class ActiveRecordDefaultsTest < Test::Unit::TestCase
  fixtures :people
  
  def test_defaults_for_new_record
    p = Person.new
    
    assert_equal 'Christchurch', p.city
    assert_equal 'New Zealand', p.country
    assert_equal 'Sean', p.first_name
    assert_equal 'Fitzpatrick', p.last_name
    assert_equal 2, p.lucky_number
  end
  
  def test_default_ignored_if_key_present
    p = Person.new(:city => '', 'lucky_number' => nil)
    
    assert_equal '', p.city
    assert_equal nil, p.lucky_number
    
    assert_equal 'New Zealand', p.country
    assert_equal 'Sean', p.first_name
    assert_equal 'Fitzpatrick', p.last_name
  end
  
  def test_existing_records_unchanged
    assert_nil Person.find(1).last_name
  end
  
  def test_default_relying_on_previous_default
    assert_equal Date.new(2006, 10, 2), Person.new.birthdate
  end
  
  def test_defaults_on_create
    p = Person.create!
    
    assert_equal 'Christchurch', p.city
    assert_equal 'New Zealand', p.country
    assert_equal 'Sean', p.first_name
    assert_equal 'Fitzpatrick', p.last_name
    assert_equal 2, p.lucky_number
  end
end
