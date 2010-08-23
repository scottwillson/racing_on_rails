require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class RaceNumberTest < ActiveSupport::TestCase
  def test_defaults
    assert_not_nil(NumberIssuer.find_by_name(ASSOCIATION.short_name), 'Number issuer exists')
    race_number = RaceNumber.new(:value => '999', :person => people(:alice))
    race_number.save!
    assert_equal(ASSOCIATION.effective_year, race_number.year, 'year default')
    assert_equal(disciplines(:road), race_number.discipline, 'year discipline')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'number issuer default')

    race_number = RaceNumber.create!(:person => people(:alice), :value => '100')
    assert_equal(ASSOCIATION.effective_year, race_number.year, 'year default')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'number issuer default')
    assert_equal(disciplines(:road), race_number.discipline, 'year discipline')
  end

  def test_create
    alice = people(:alice)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    assert_equal(alice, race_number.person, 'New number person')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer person')
    assert_equal(disciplines(:road), race_number.discipline, 'New number discipline')
    
    # One field different
    RaceNumber.create!(:person => alice, :value => 'A104', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    RaceNumber.create!(:person => alice, :value => 'A103', :year => 2002, :number_issuer => elkhorn, :discipline => disciplines(:road))
    obra = NumberIssuer.find_or_create_by_name('OBRA')
    RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => obra, :discipline => disciplines(:road))
    RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:track))
    
    # dupes OK if different person 
    assert(RaceNumber.new(:person => alice, :value => '999', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'Same person, same value')
    assert(RaceNumber.new(:person => people(:molly), :value => '999', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'Different people, same value')
    
    # invalid because missing fields
    assert(!RaceNumber.new(:person => alice, :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'No value')
    assert(!RaceNumber.new(:person => alice, :value => '', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'Blank value')
    
    # No person ID valid when new, but can't save
    no_person = RaceNumber.new(:value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    assert(no_person.valid?, "No person result should be valid, but: #{no_person.errors.full_messages}")
    assert_raise(ActiveRecord::StatementInvalid) {no_person.save!}
    
    no_person = RaceNumber.new(:value => '1009', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    assert(no_person.valid?, 'No person')
    assert_raise(ActiveRecord::StatementInvalid) {no_person.save!}
    
    # Defaults
    race_number = RaceNumber.new(:person => alice, :value => 'A1', :number_issuer => elkhorn, :discipline => disciplines(:road))
    assert(race_number.valid?, 'No year')
    race_number.save!
    
    race_number = RaceNumber.new(:person => alice, :value => '9000', :year => 2001, :discipline => disciplines(:road))
    assert(race_number.valid?, "no issuer: #{race_number.errors.full_messages}")
    race_number.save!
    
    race_number = RaceNumber.new(:person => alice, :value => '9103', :year => 2001, :number_issuer => elkhorn)
    assert(race_number.valid?, "No discipline: #{race_number.errors.full_messages}")
    race_number.save!
  end

  def test_cannot_create_exact_same_number_for_person
    alice = people(:alice)
    obra = NumberIssuer.find_or_create_by_name('OBRA')

    RaceNumber.create!(:person => alice, :value => '876', :year => 2001, :number_issuer => obra, :discipline => disciplines(:cyclocross))
    number = RaceNumber.create(:person => alice, :value => '876', :year => 2001, :number_issuer => obra, :discipline => disciplines(:cyclocross))
    assert(!number.valid?, "Should not be able to create two of the exact same numbers")
  end  

  def test_create_cyclocross
    alice = people(:alice)
    
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    assert_equal(alice, race_number.person, 'New number person')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer person')
    assert_equal(disciplines(:cyclocross), race_number.discipline, 'New number discipline')
    
    # One field different
    RaceNumber.create!(:person => alice, :value => 'A104', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    RaceNumber.create!(:person => alice, :value => 'A103', :year => 2002, :number_issuer => elkhorn, :discipline => disciplines(:road))
    obra = NumberIssuer.find_or_create_by_name('OBRA')
    RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => obra, :discipline => disciplines(:cyclocross))
    RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:track))
    
    # dupes always OK with cyclocross, even if different person 
    assert(RaceNumber.new(:person => alice, :value => '9000', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross)).valid?, 'Same person, same value')
    assert(RaceNumber.new(:person => people(:molly), :value => '9000', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross)).valid?, 'Different people, same value')
    
    # invalid because missing fields
    assert(!RaceNumber.new(:person => alice, :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross)).valid?, 'No value')
    assert(!RaceNumber.new(:person => alice, :value => '', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross)).valid?, 'Blank value')
    
    # No person ID valid when new, but can't save
    no_person = RaceNumber.new(:value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    assert(no_person.valid?, 'No person')
    assert_raise(ActiveRecord::StatementInvalid) {no_person.save!}
    
    no_person = RaceNumber.new(:value => '1009', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    assert(no_person.valid?, 'No person')
    assert_raise(ActiveRecord::StatementInvalid) {no_person.save!}
    
    # Defaults
    race_number = RaceNumber.new(:person => alice, :value => 'A1', :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    assert(race_number.valid?, 'No year')
    race_number.save!
    
    race_number = RaceNumber.new(:person => alice, :value => '9000', :year => 2001, :discipline => disciplines(:cyclocross))
    assert(race_number.valid?, "no issuer: #{race_number.errors.full_messages}")
    race_number.save!
    
    race_number = RaceNumber.new(:person => alice, :value => '9103', :year => 2001, :number_issuer => elkhorn)
    assert(race_number.valid?, "No discipline: #{race_number.errors.full_messages}")
    race_number.save!
  end
  
  def test_rental
    alice = people(:alice)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    
    begin
      original_rental_numbers = ASSOCIATION.rental_numbers
      ASSOCIATION.rental_numbers = 11..99
      assert(RaceNumber.new(:person => alice, :value => '10', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(!RaceNumber.new(:person => alice, :value => '11', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(!RaceNumber.new(:person => alice, :value => ' 78', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(!RaceNumber.new(:person => alice, :value => '99', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:person => alice, :value => '100', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
    
      assert(RaceNumber.rental?(nil), 'Nil number is rental')
      assert(RaceNumber.rental?(''), 'Blank number is rental')
      assert(!RaceNumber.rental?(' 9 '), '9 not rental')
      assert(RaceNumber.rental?('11'), '11 is rental')
      assert(RaceNumber.rental?('99'), '99 is rental')
      assert(!RaceNumber.rental?('11', Discipline[:downhill]), '11 is rental')
      assert(!RaceNumber.rental?('99', Discipline[:mountain_bike]), '99 is rental')
      assert(!RaceNumber.rental?('100'), '100 not rental')
      assert(!RaceNumber.rental?('A100'), 'A100 not rental')
      assert(!RaceNumber.rental?('A50'), 'A50 not rental')
      assert(!RaceNumber.rental?('50Z'), '50Z not rental')

      ASSOCIATION.rental_numbers = nil
      assert(RaceNumber.new(:person => alice, :value => '10', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:person => alice, :value => '11', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:person => alice, :value => ' 78', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:person => alice, :value => '99', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:person => alice, :value => '100', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
    
      assert(!RaceNumber.rental?(nil), 'Nil number not rental')
      assert(!RaceNumber.rental?(''), 'Blank number not rental')
      assert(!RaceNumber.rental?(' 9 '), '9 not rental')
      assert(!RaceNumber.rental?('11'), '11 is rental')
      assert(!RaceNumber.rental?('99'), '99 is rental')
      assert(!RaceNumber.rental?('100'), '100 not rental')
      assert(!RaceNumber.rental?('A100'), 'A100 not rental')
      assert(!RaceNumber.rental?('A50'), 'A50 not rental')
      assert(!RaceNumber.rental?('50Z'), '50Z not rental')
    ensure
      ASSOCIATION.rental_numbers = original_rental_numbers
    end
  end
  
  def test_create_bmx
    alice = people(:alice)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:bmx))
    assert_equal(alice, race_number.person, 'New number person')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer person')
    assert_equal(disciplines(:bmx), race_number.discipline, 'New number discipline')
  end
  
  def test_destroy
    alice = people(:alice)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:bmx))
    alice.results.clear
    alice.destroy
    assert(!RaceNumber.exists?(:person_id => alice.id, :value => 'A103'), "Shoud delete person")
  end
  
  def test_gender
    alice = people(:alice)
    tonkin = people(:tonkin)
    
    begin
      original_gender_specific_numbers = ASSOCIATION.gender_specific_numbers?
      ASSOCIATION.gender_specific_numbers = false

      race_number = RaceNumber.new(:person => alice, :value => '9103')
      assert(race_number.valid?, "Default non-gender-specific number: #{race_number.errors.full_messages}")
      
      race_number = RaceNumber.create!(:person => tonkin, :value => '200')
      assert(race_number.valid?, "Default non-gender-specific number: #{race_number.errors.full_messages}")

      race_number = RaceNumber.new(:person => alice, :value => '200')
      assert(race_number.valid?, 'Dupe number for different gender should be valid')

      original_gender_specific_numbers = ASSOCIATION.gender_specific_numbers?
      ASSOCIATION.gender_specific_numbers = true

      race_number = RaceNumber.create!(:person => alice, :value => '200')
      assert(race_number.valid?, 'Dupe number for different gender should be valid')

      race_number = RaceNumber.new(:person => people(:molly), :value => '200')
      assert(race_number.valid?, 'Dupe number for same gender should be valid')
    ensure
      ASSOCIATION.gender_specific_numbers = original_gender_specific_numbers
    end
  end
end