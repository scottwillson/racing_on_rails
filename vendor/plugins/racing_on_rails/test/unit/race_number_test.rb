require File.dirname(__FILE__) + '/../test_helper'

class RaceNumberTest < Test::Unit::TestCase
  def test_defaults
    race_number = RaceNumber.new
    assert_equal(Date.today.year, race_number.year, 'year default')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'number issuer default')
    assert_equal(disciplines(:road), race_number.discipline, 'year discipline')

    race_number = RaceNumber.create!(:racer => racers(:alice), :value => '7')
    assert_equal(Date.today.year, race_number.year, 'year default')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'number issuer default')
    assert_equal(disciplines(:road), race_number.discipline, 'year discipline')
  end

  def test_create
    alice = racers(:alice)
    elkhorn = NumberIssuer.create!(:name => 'Elkhorn Classic SR')
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    
    # One field different
    RaceNumber.create!(:racer => alice, :value => 'A104', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2002, :number_issuer => elkhorn, :discipline => disciplines(:road))
    obra = NumberIssuer.create!(:name => 'OBRA')
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => obra, :discipline => disciplines(:road))
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:track))
    
    # dupes (OK now, were not before)
    RaceNumber.create!(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    RaceNumber.create!(:racer => racers(:mollie), :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    
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
    
    race_number = RaceNumber.new(:racer => alice, :value => 'A103', :year => 2001, :discipline => disciplines(:road))
    assert(race_number.valid?, "no issuer")
    race_number.save!
    
    race_number = RaceNumber.new(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn)
    assert(race_number.valid?, 'No discipline')
    race_number.save!
  end
end