require File.dirname(__FILE__) + '/../test_helper'

class RaceNumberTest < Test::Unit::TestCase
  def test_defaults
    assert_not_nil(NumberIssuer.find_by_name(ASSOCIATION.short_name), 'Number issuer exists')
    race_number = RaceNumber.new
    assert_equal(Date.today.year, race_number.year, 'year default')
    assert_equal(disciplines(:road), race_number.discipline, 'year discipline')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'number issuer default')

    race_number = RaceNumber.create!(:racer => racers(:alice), :value => '7')
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
    
    # dupes OK if different racer 
    assert(!RaceNumber.new(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
    assert(RaceNumber.new(:racer => racers(:mollie), :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?)
    
    # invalid because missing fields
    assert(!RaceNumber.new(:racer => alice, :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'No value')
    assert(!RaceNumber.new(:value => '', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'Blank value')
    
    # No racer ID valid when new, but can't save
    no_racer = RaceNumber.new(:value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
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
end