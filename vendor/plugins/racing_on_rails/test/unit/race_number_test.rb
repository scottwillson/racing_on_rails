require File.dirname(__FILE__) + '/../test_helper'

class RaceNumberTest < Test::Unit::TestCase

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
    assert(!RaceNumber.new(:value => 'A1', :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'No year')
    assert(!RaceNumber.new(:racer => alice, :value => 'A103', :year => 2001, :discipline => disciplines(:road)).valid?, 'No issuer')
    assert(!RaceNumber.new(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn).valid?, 'No discipline')
    
    # No racer ID valid when new, but can't save
    no_racer = RaceNumber.new(:value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    assert(no_racer.valid?, 'No racer')
    assert_raise(ActiveRecord::StatementInvalid) {no_racer.save!}
  end
end