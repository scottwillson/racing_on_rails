require File.dirname(__FILE__) + '/../test_helper'

class RaceNumberTest < ActiveSupport::TestCase
  def test_defaults
    assert_not_nil(NumberIssuer.find_by_name(ASSOCIATION.short_name), 'Number issuer exists')
    race_number = RaceNumber.new(:value => '999', :racer => racers(:alice))
    race_number.save!
    assert_equal(Date.today.year, race_number.year, 'year default')
    assert_equal(disciplines(:road), race_number.discipline, 'year discipline')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'number issuer default')

    race_number = RaceNumber.create!(:racer => racers(:alice), :value => '100')
    assert_equal(Date.today.year, race_number.year, 'year default')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'number issuer default')
    assert_equal(disciplines(:road), race_number.discipline, 'year discipline')
  end

  def test_create
    alice = racers(:alice)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    assert_equal(alice, race_number.racer, 'New number racer')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer racer')
    assert_equal(disciplines(:road), race_number.discipline, 'New number discipline')
    
    # One field different
    RaceNumber.create!(:racer => alice, :value => 'A104', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2002, :number_issuer => elkhorn, :discipline => disciplines(:road))
    obra = NumberIssuer.find_or_create_by_name('OBRA')
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => obra, :discipline => disciplines(:road))
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:track))
    
    # dupes not OK if different racer 
    assert(RaceNumber.new(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'Same racer, same value')
    assert(!RaceNumber.new(:racer => racers(:molly), :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'Different racers, same value')
    
    # invalid because missing fields
    assert(!RaceNumber.new(:racer => alice, :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'No value')
    assert(!RaceNumber.new(:racer => alice, :value => '', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'Blank value')
    
    # No racer ID valid when new, but can't save
    no_racer = RaceNumber.new(:value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    assert(no_racer.valid?, 'No racer')
    assert_raise(ActiveRecord::StatementInvalid) {no_racer.save!}
    
    no_racer = RaceNumber.new(:value => '1009', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    assert(no_racer.valid?, 'No racer')
    assert_raise(ActiveRecord::StatementInvalid) {no_racer.save!}
    
    # Defaults
    race_number = RaceNumber.new(:racer => alice, :value => 'A1', :number_issuer => elkhorn, :discipline => disciplines(:road))
    assert(race_number.valid?, 'No year')
    race_number.save!
    
    race_number = RaceNumber.new(:racer => alice, :value => '9000', :year => 2001, :discipline => disciplines(:road))
    assert(race_number.valid?, "no issuer: #{race_number.errors.full_messages}")
    race_number.save!
    
    race_number = RaceNumber.new(:racer => alice, :value => '9103', :year => 2001, :number_issuer => elkhorn)
    assert(race_number.valid?, "No discipline: #{race_number.errors.full_messages}")
    race_number.save!
  end

  def test_create_cyclocross
    alice = racers(:alice)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    assert_equal(alice, race_number.racer, 'New number racer')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer racer')
    assert_equal(disciplines(:cyclocross), race_number.discipline, 'New number discipline')
    
    # One field different
    RaceNumber.create!(:racer => alice, :value => 'A104', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2002, :number_issuer => elkhorn, :discipline => disciplines(:road))
    obra = NumberIssuer.find_or_create_by_name('OBRA')
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => obra, :discipline => disciplines(:cyclocross))
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:track))
    
    # dupes always OK with cyclocross, even if different racer 
    assert(RaceNumber.new(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross)).valid?, 'Same racer, same value')
    assert(RaceNumber.new(:racer => racers(:molly), :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross)).valid?, 'Different racers, same value')
    
    # invalid because missing fields
    assert(!RaceNumber.new(:racer => alice, :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross)).valid?, 'No value')
    assert(!RaceNumber.new(:racer => alice, :value => '', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross)).valid?, 'Blank value')
    
    # No racer ID valid when new, but can't save
    no_racer = RaceNumber.new(:value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    assert(no_racer.valid?, 'No racer')
    assert_raise(ActiveRecord::StatementInvalid) {no_racer.save!}
    
    no_racer = RaceNumber.new(:value => '1009', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    assert(no_racer.valid?, 'No racer')
    assert_raise(ActiveRecord::StatementInvalid) {no_racer.save!}
    
    # Defaults
    race_number = RaceNumber.new(:racer => alice, :value => 'A1', :number_issuer => elkhorn, :discipline => disciplines(:cyclocross))
    assert(race_number.valid?, 'No year')
    race_number.save!
    
    race_number = RaceNumber.new(:racer => alice, :value => '9000', :year => 2001, :discipline => disciplines(:cyclocross))
    assert(race_number.valid?, "no issuer: #{race_number.errors.full_messages}")
    race_number.save!
    
    race_number = RaceNumber.new(:racer => alice, :value => '9103', :year => 2001, :number_issuer => elkhorn)
    assert(race_number.valid?, "No discipline: #{race_number.errors.full_messages}")
    race_number.save!
  end
  
  def test_rental
    alice = racers(:alice)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    
    begin
      original_rental_numbers = ASSOCIATION.rental_numbers
      ASSOCIATION.rental_numbers = 11..99
      assert(RaceNumber.new(:racer => alice, :value => '10', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(!RaceNumber.new(:racer => alice, :value => '11', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(!RaceNumber.new(:racer => alice, :value => ' 78', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(!RaceNumber.new(:racer => alice, :value => '99', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:racer => alice, :value => '100', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
    
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
      assert(RaceNumber.new(:racer => alice, :value => '10', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:racer => alice, :value => '11', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:racer => alice, :value => ' 78', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:racer => alice, :value => '99', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
      assert(RaceNumber.new(:racer => alice, :value => '100', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
    
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
    alice = racers(:alice)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    race_number = RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:bmx))
    assert_equal(alice, race_number.racer, 'New number racer')
    assert_equal(2001, race_number.year, 'New number year')
    assert_equal(elkhorn, race_number.number_issuer, 'New number_issuer racer')
    assert_equal(disciplines(:bmx), race_number.discipline, 'New number discipline')
  end
  
  def test_gender
    alice = racers(:alice)
    tonkin = racers(:tonkin)
    
    begin
      original_gender_specific_numbers = ASSOCIATION.gender_specific_numbers?
      ASSOCIATION.gender_specific_numbers = false

      race_number = RaceNumber.new(:racer => alice, :value => '9103')
      assert(race_number.valid?, "Default non-gender-specific number: #{race_number.errors.full_messages}")
      
      race_number = RaceNumber.create!(:racer => tonkin, :value => '200')
      assert(race_number.valid?, "Default non-gender-specific number: #{race_number.errors.full_messages}")

      race_number = RaceNumber.new(:racer => alice, :value => '200')
      assert(!race_number.valid?, 'Dupe number for different gender should not be valid')

      original_gender_specific_numbers = ASSOCIATION.gender_specific_numbers?
      ASSOCIATION.gender_specific_numbers = true

      race_number = RaceNumber.create!(:racer => alice, :value => '200')
      assert(race_number.valid?, 'Dupe number for different gender should be valid')

      race_number = RaceNumber.new(:racer => racers(:molly), :value => '200')
      assert(!race_number.valid?, 'Dupe number for same gender should not be valid')
    ensure
      ASSOCIATION.gender_specific_numbers = original_gender_specific_numbers
    end
  end
end