require File.dirname(__FILE__) + '/../test_helper'

class NumberIssuerTest < Test::Unit::TestCase

  fixtures :disciplines, :categories, :teams, :racers, :promoters, :events, :standings, :races, :results, :aliases, :promoters, :number_issuers, :race_numbers

  def test_create
    NumberIssuer.create(:name => 'Elkhorn Classic SR')
    assert(!NumberIssuer.new.valid?, 'Null name')
    assert(!NumberIssuer.new(:name => '').valid?, 'Empty name')
  end
end