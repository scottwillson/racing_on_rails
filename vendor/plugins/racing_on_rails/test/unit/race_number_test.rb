require File.dirname(__FILE__) + '/../test_helper'

class RaceNumberTest < Test::Unit::TestCase

  fixtures :disciplines, :teams, :racers, :aliases, :promoters, :categories, :number_issuers, :race_numbers, :racers, :events, :standings, :races, :results

  def test_create
    alice = racers(:alice)
    elkhorn = NumberIssuer.create(:name => 'Elkhorn Classic SR')
    RaceNumber.create(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road))
    
    assert(!RaceNumber.new(:value => 'A103', :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'No racer')
    assert(!RaceNumber.new(:racer => alice, :year => 2001, :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'No value')
    assert(!RaceNumber.new(:value => '', :number_issuer => elkhorn, :discipline => disciplines(:road)).valid?, 'No year')
    assert(!RaceNumber.new(:racer => alice, :value => 'A103', :year => 2001, :discipline => disciplines(:road)).valid?, 'No issuer')
    assert(!RaceNumber.new(:racer => alice, :value => 'A103', :year => 2001, :number_issuer => elkhorn).valid?, 'No discipline')
  end
end