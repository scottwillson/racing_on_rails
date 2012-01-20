require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class RaceNumberTest < ActiveSupport::TestCase
  def test_defaults
    number_issuer = FactoryGirl.create(:number_issuer)
    road = FactoryGirl.create(:discipline, :name => "Road")

    assert_not_nil(NumberIssuer.find_by_name(RacingAssociation.current.short_name), 'Number issuer exists')
    person = FactoryGirl.create(:person)
    race_number = RaceNumber.create!(:value => '999', :person => person)
    assert_equal(RacingAssociation.current.effective_year, race_number.year, 'year default')
    assert_equal(road, race_number.discipline, 'year discipline')
    assert_equal(number_issuer, race_number.number_issuer, 'number issuer default')

    race_number = RaceNumber.create!(:person => person, :value => '100')
    assert_equal(RacingAssociation.current.effective_year, race_number.year, 'year default')
    assert_equal(number_issuer, race_number.number_issuer, 'number issuer default')
    assert_equal(road, race_number.discipline, 'year discipline')
  end

  def test_create
    number_issuer = FactoryGirl.create(:number_issuer)
    road = FactoryGirl.create(:discipline, :name => "Road")
    track = FactoryGirl.create(:discipline, :name => "Track")
    alice = FactoryGirl.create(:person)
    molly = FactoryGirl.create(:person)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => road)
    assert_equal(alice, race_number.person, 'New number person')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer person')
    assert_equal(road, race_number.discipline, 'New number discipline')
    
    # One field different
    RaceNumber.create!(:person => alice, :value => 'A104', :year => 2001, :number_issuer => elkhorn, :discipline => road)
    RaceNumber.create!(:person => alice, :value => 'A103', :year => 2002, :number_issuer => elkhorn, :discipline => road)
    obra = NumberIssuer.find_or_create_by_name('CBRA')
    RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => obra, :discipline => road)
    RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => track)
    
    # dupes OK if different person 
    assert(RaceNumber.new(:person => alice, :value => '999', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?, 'Same person, same value')
    assert(RaceNumber.new(:person => molly, :value => '999', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?, 'Different people, same value')
    
    # invalid because missing fields
    assert(!RaceNumber.new(:person => alice, :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?, 'No value')
    assert(!RaceNumber.new(:person => alice, :value => '', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?, 'Blank value')
    
    # No person ID valid when new, but can't save
    no_person = RaceNumber.new(:value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => road)
    assert(no_person.valid?, "No person result should be valid, but: #{no_person.errors.full_messages}")
    assert_raise(ActiveRecord::InvalidForeignKey) {no_person.save!}
    
    no_person = RaceNumber.new(:value => '1009', :year => 2001, :number_issuer => elkhorn, :discipline => road)
    assert(no_person.valid?, 'No person')
    assert_raise(ActiveRecord::InvalidForeignKey) {no_person.save!}
    
    # Defaults
    race_number = RaceNumber.new(:person => alice, :value => 'A1', :number_issuer => elkhorn, :discipline => road)
    assert(race_number.valid?, 'No year')
    race_number.save!
    
    race_number = RaceNumber.new(:person => alice, :value => '9000', :year => 2001, :discipline => road)
    assert(race_number.valid?, "no issuer: #{race_number.errors.full_messages}")
    race_number.save!
    
    race_number = RaceNumber.new(:person => alice, :value => '9103', :year => 2001, :number_issuer => elkhorn)
    assert(race_number.valid?, "No discipline: #{race_number.errors.full_messages}")
    race_number.save!
  end

  def test_cannot_create_exact_same_number_for_person
    alice = FactoryGirl.create(:person)
    obra = NumberIssuer.find_or_create_by_name('CBRA')
    cyclocross = FactoryGirl.create(:discipline, :name => "Cyclocross")
    road = FactoryGirl.create(:discipline, :name => "Road")

    RaceNumber.create!(:person => alice, :value => '876', :year => 2001, :number_issuer => obra, :discipline => cyclocross)
    number = RaceNumber.create(:person => alice, :value => '876', :year => 2001, :number_issuer => obra, :discipline => cyclocross)
    assert(!number.valid?, "Should not be able to create two of the exact same numbers")
  end  

  def test_rental
    alice = FactoryGirl.create(:person)
    number_issuer = FactoryGirl.create(:number_issuer)
    road = FactoryGirl.create(:discipline, :name => "Road")
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    
    assert(RaceNumber.new(:person => alice, :value => '10', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '11', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => ' 78', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '99', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '100', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
  
    assert(RaceNumber.rental?(nil), 'Nil number is rental')
    assert(RaceNumber.rental?(''), 'Blank number is rental')
    assert(!RaceNumber.rental?(' 9 '), '9 not rental')
    assert(!RaceNumber.rental?('11'), '11 is not a rental')
    assert(RaceNumber.rental?('99'), '99 is rental')
    assert(!RaceNumber.rental?('11', Discipline[:downhill]), '11 is rental')
    assert(!RaceNumber.rental?('99', Discipline[:mountain_bike]), '99 is rental')
    assert(!RaceNumber.rental?('100'), '100 not rental')
    assert(!RaceNumber.rental?('A100'), 'A100 not rental')
    assert(!RaceNumber.rental?('A50'), 'A50 not rental')
    assert(!RaceNumber.rental?('50Z'), '50Z not rental')

    assert(RaceNumber.new(:person => alice, :value => '10', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '11', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    race_number = RaceNumber.new(:person => alice, :value => ' 78', :year => 2001, :number_issuer => elkhorn, :discipline => road)
    assert race_number.valid?, race_number.errors.full_messages.join(", ")
    assert(RaceNumber.new(:person => alice, :value => '99', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '100', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
  
    assert(RaceNumber.rental?(nil), 'Nil number rental')
    assert(RaceNumber.rental?(''), 'Blank number rental')
    assert(!RaceNumber.rental?(' 9 '), '9 not rental')
    assert(!RaceNumber.rental?('11'), '11 is rental')
    assert(RaceNumber.rental?('99'), '99 is rental')
    assert(!RaceNumber.rental?('100'), '100 not rental')
    assert(!RaceNumber.rental?('A100'), 'A100 not rental')
    assert(!RaceNumber.rental?('A50'), 'A50 not rental')
    assert(!RaceNumber.rental?('50Z'), '50Z not rental')
  end

  def test_rental_no_rental_numbers
    alice = FactoryGirl.create(:person)
    racing_association = RacingAssociation.current
    racing_association.rental_numbers = nil
    racing_association.save!
    number_issuer = FactoryGirl.create(:number_issuer)
    road = FactoryGirl.create(:discipline, :name => "Road")
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    
    assert(RaceNumber.new(:person => alice, :value => '10', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '11', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => ' 78', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '99', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '100', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
  
    assert(!RaceNumber.rental?(nil), 'Nil number is rental')
    assert(!RaceNumber.rental?(''), 'Blank number is rental')
    assert(!RaceNumber.rental?(' 9 '), '9 not rental')
    assert(!RaceNumber.rental?('11'), '11 is not a rental')
    assert(!RaceNumber.rental?('99'), '99 is rental')
    assert(!RaceNumber.rental?('11', Discipline[:downhill]), '11 is rental')
    assert(!RaceNumber.rental?('99', Discipline[:mountain_bike]), '99 is rental')
    assert(!RaceNumber.rental?('100'), '100 not rental')
    assert(!RaceNumber.rental?('A100'), 'A100 not rental')
    assert(!RaceNumber.rental?('A50'), 'A50 not rental')
    assert(!RaceNumber.rental?('50Z'), '50Z not rental')

    assert(RaceNumber.new(:person => alice, :value => '10', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '11', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    race_number = RaceNumber.new(:person => alice, :value => ' 78', :year => 2001, :number_issuer => elkhorn, :discipline => road)
    assert race_number.valid?, race_number.errors.full_messages.join(", ")
    assert(RaceNumber.new(:person => alice, :value => '99', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
    assert(RaceNumber.new(:person => alice, :value => '100', :year => 2001, :number_issuer => elkhorn, :discipline => road).valid?)
  
    assert(!RaceNumber.rental?(nil), 'Nil number not rental')
    assert(!RaceNumber.rental?(''), 'Blank number not rental')
    assert(!RaceNumber.rental?(' 9 '), '9 not rental')
    assert(!RaceNumber.rental?('11'), '11 is not a rental')
    assert(!RaceNumber.rental?('99'), '99 is not a rental')
    assert(!RaceNumber.rental?('100'), '100 not rental')
    assert(!RaceNumber.rental?('A100'), 'A100 not rental')
    assert(!RaceNumber.rental?('A50'), 'A50 not rental')
    assert(!RaceNumber.rental?('50Z'), '50Z not rental')
  end
  
  def test_create_bmx
    alice = FactoryGirl.create(:person)
    number_issuer = FactoryGirl.create(:number_issuer)
    road = FactoryGirl.create(:discipline, :name => "Road")
    bmx = FactoryGirl.create(:discipline, :name => "BMX")
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => bmx)
    assert_equal(alice, race_number.person, 'New number person')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer person')
    assert_equal(bmx, race_number.discipline, 'New number discipline')
  end
  
  def test_destroy
    alice = FactoryGirl.create(:person)
    number_issuer = FactoryGirl.create(:number_issuer)
    road = FactoryGirl.create(:discipline, :name => "Road")
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:person => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn)
    alice.results.clear
    alice.destroy
    assert(!RaceNumber.exists?(:person_id => alice.id, :value => 'A103'), "Shoud delete person")
  end
  
  def test_gender
    alice = FactoryGirl.create(:person)
    tonkin = FactoryGirl.create(:person)
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, :name => "Road")
    
    RacingAssociation.current.gender_specific_numbers = false
    
    race_number = RaceNumber.new(:person => alice, :value => '9103')
    assert(race_number.valid?, "Default non-gender-specific number: #{race_number.errors.full_messages}")
    
    race_number = RaceNumber.create!(:person => tonkin, :value => '200')
    assert(race_number.valid?, "Default non-gender-specific number: #{race_number.errors.full_messages}")

    race_number = RaceNumber.new(:person => alice, :value => '200')
    assert(race_number.valid?, 'Dupe number for different gender should be valid')
  end
  
  def test_gender_alt
    alice = FactoryGirl.create(:person)
    tonkin = FactoryGirl.create(:person)
    molly = FactoryGirl.create(:person)

    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, :name => "Road")

    RacingAssociation.current.gender_specific_numbers = true

    race_number = RaceNumber.create!(:person => alice, :value => '200')
    assert(race_number.valid?, 'Dupe number for different gender should be valid')

    race_number = RaceNumber.new(:person => molly, :value => '200')
    assert(race_number.valid?, 'Dupe number for same gender should be valid')
  end
end
